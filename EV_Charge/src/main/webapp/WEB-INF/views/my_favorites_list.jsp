<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <script src="${pageContext.request.contextPath}/js/jquery.js"></script>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 즐겨찾는 충전소</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        /* ... (CSS 스타일은 이전과 동일하게 유지) ... */
        body { font-family: sans-serif; margin: 0; background-color: #f4f4f4; color: #333; }
        .my-favorites-container { max-width: 800px; margin: 20px auto; background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        /* ... (나머지 스타일) ... */
    </style>

    <%-- ⭐ 3. user_no 와 contextPath를 window.myApp 전역 네임스페이스에 설정 (가장 중요!) ⭐ --%>
    <%-- 이 스크립트는 다른 어떤 애플리케이션 레벨 JS보다 먼저 실행되어야 합니다. --%>
    <script>
        window.myApp = window.myApp || {}; // 전역 네임스페이스 객체 생성

        // contextPath 설정 (JSP EL은 서버에서 HTML 생성 시 값으로 치환됨)
        window.myApp.contextPath = "${pageContext.request.contextPath}";
        console.log('[HEAD SCRIPT] window.myApp.contextPath 설정:', window.myApp.contextPath);

        // user_no 설정
        <c:choose>
            <c:when test="${not empty sessionScope.user && not empty sessionScope.user.user_no}">
                window.myApp.userNo = parseInt(${sessionScope.user.user_no});
                console.log('[HEAD SCRIPT] window.myApp.userNo 설정:', window.myApp.userNo);
            </c:when>
            <c:otherwise>
                window.myApp.userNo = null;
                console.warn('[HEAD SCRIPT] 사용자 정보 없음. window.myApp.userNo는 null.');
            </c:otherwise>
        </c:choose>

        // 전역 userFavoriteStationIds 초기화 (빈 Set으로 우선 선언)
        window.myApp.userFavoriteStationIds = new Set();
        console.log('[HEAD SCRIPT] window.myApp.userFavoriteStationIds 빈 Set으로 초기 선언.');
    </script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/header.jsp" />

    <div class="my-favorites-container">
        <header class="favorites-header">
            <h1><i class="fas fa-star"></i> 내 즐겨찾는 충전소</h1>
            <a href="${pageContext.request.contextPath}/main" class="back-to-map-btn">
                <i class="fas fa-map-marked-alt"></i> 지도로 돌아가기
            </a>
        </header>
        <main id="favorites-list-content">
            <div class="message-area loading-favorites"><p><i class="fas fa-spinner fa-spin"></i> 즐겨찾기 목록을 불러오는 중입니다...</p></div>
            <div class="message-area empty-favorites" style="display:none;"><p><i class="fas fa-info-circle"></i> 즐겨찾기한 충전소가 없습니다.</p><p>지도에서 충전소를 검색하고 <i class="fas fa-star"></i> 아이콘을 눌러 즐겨찾기에 추가해보세요.</p></div>
            <div class="message-area login-required" style="display:none;"><p><i class="fas fa-exclamation-triangle"></i> 로그인이 필요한 서비스입니다.</p><p><a href="${pageContext.request.contextPath}/login">로그인 페이지로 이동</a></p></div>
            <ul id="favorite-station-list" class="station-list-ul"></ul>
        </main>
    </div>

    <script>
    // ⭐ 메인 스크립트 블록 (DOMContentLoaded 내) ⭐
    document.addEventListener('DOMContentLoaded', async function () { // DOMContentLoaded를 async로 변경
        // 전역 네임스페이스에서 변수 가져오기 (이 시점에는 <head>의 스크립트가 실행되어 값이 설정되어 있어야 함)
        const user_no = window.myApp.userNo;
        const contextPath = window.myApp.contextPath;

        console.log('[MY_FAVORITES_LIST - DOMContentLoaded] user_no:', user_no, '(타입:', typeof user_no, ')');
        console.log('[MY_FAVORITES_LIST - DOMContentLoaded] contextPath:', contextPath, '(타입:', typeof contextPath, ')');

        const favoritesListElement = document.getElementById('favorite-station-list');
        const loadingMessageDiv = document.querySelector('.loading-favorites');
        const emptyMessageDiv = document.querySelector('.empty-favorites');
        const loginRequiredDiv = document.querySelector('.login-required');

        // 전역 즐겨찾기 목록을 가져오는 함수 (비동기)
        // 이 함수는 애플리케이션 로드 시 한 번만 호출되는 것이 가장 이상적 (예: main.jsp 또는 공통 헤더)
        // 여기서는 이 페이지에만 있다고 가정하고, DOM 로드 후 user_no가 있을 때 호출합니다.
        async function fetchAndSetInitialFavoritesLocal() {
            if (!isUserLoggedIn()) { // user_no를 여기서 다시 사용
                console.log("[fetchAndSetInitialFavoritesLocal] 로그인 상태 아니거나 user_no 유효하지 않아 즐겨찾기 목록 로드 안 함.");
                // window.myApp.userFavoriteStationIds는 이미 빈 Set임
                return; // 여기서 함수 종료
            }
            // contextPath 유효성 검사
            if (typeof contextPath !== 'string' || (contextPath === "" && window.location.pathname !== "/")) {
                 // 루트 배포가 아닌데 contextPath가 비어있으면 문제
                 // (루트 배포 시 contextPath는 ""일 수 있음)
                 // 여기서는 contextPath가 유효한 문자열이어야 API 호출이 가능하다고 가정
                if (contextPath === "" && window.location.pathname.startsWith("/")) {
                     // 루트 배포로 간주, 계속 진행
                } else if (!contextPath) {
                    console.error("[fetchAndSetInitialFavoritesLocal] contextPath가 유효하지 않아 API 호출 불가!", contextPath);
                    return;
                }
            }

            try {
                console.log(`[fetchAndSetInitialFavoritesLocal] 전역 즐겨찾기 목록 로드 시도 (user_no: ${user_no})`);
                const response = await fetch(`${contextPath}/favorite/status?user_no=${user_no}`);
                if (!response.ok) {
                    const errorText = await response.text().catch(()=>`서버 응답 (${response.status}) 읽기 실패`);
                    console.warn(`[fetchAndSetInitialFavoritesLocal] 즐겨찾기 상태 API 응답 오류: ${response.status} - ${errorText}`);
                    return;
                }
                const data = await response.json();
                if (data.status === 'success' && Array.isArray(data.favoriteStationIds)) {
                    window.myApp.userFavoriteStationIds = new Set(data.favoriteStationIds);
                    console.log('[fetchAndSetInitialFavoritesLocal] window.myApp.userFavoriteStationIds 초기화 완료:', Array.from(window.myApp.userFavoriteStationIds));
                } else {
                    console.warn('[fetchAndSetInitialFavoritesLocal] window.myApp.userFavoriteStationIds 초기화 실패(API 응답 문제):', data.message || data);
                }
            } catch (e) {
                console.error("[fetchAndSetInitialFavoritesLocal] window.myApp.userFavoriteStationIds 초기화 중 예외:", e);
            }
        }


        function isUserLoggedIn() {
            return typeof user_no === 'number' && !isNaN(user_no) && user_no > 0;
        }

        function createFavoriteItemHTML(station) {
            const currentFavorites = window.myApp.userFavoriteStationIds || new Set();
            const isActive = currentFavorites.has(station.stat_id);
            const stationName = station.stn_place || '이름 정보 없음';
            const stationAddress = station.stn_addr || '주소 정보 없음';
            const stationLat = station.evse_location_latitude || '-';
            const stationLng = station.evse_location_longitude || '-';
            const stationNameForDataAttr = stationName.replace(/"/g, '&quot;');

            return `
                <li class="favorite-item" data-stat-id="${station.stat_id}" data-lat="${stationLat}" data-lng="${stationLng}" data-stn-place="${stationNameForDataAttr}">
                    <div class="station-details">
                        <h3 class="station-name">${stationName}</h3>
                        <p class="station-address"><i class="fas fa-map-marker-alt"></i> ${stationAddress}</p>
                        <p class="station-coords">위도: ${stationLat}, 경도: ${stationLng}</p>
                    </div>
                    <div class="station-actions">
                        <button class="favorite-toggle-btn ${isActive ? 'active' : ''}" title="${isActive ? '즐겨찾기에서 제거' : '즐겨찾기에 추가'}"><i class="fas fa-star"></i></button>
                        <button class="view-on-map-btn" title="지도에서 보기"><i class="fas fa-search-location"></i></button>
                    </div>
                </li>`;
        }

        async function loadFavorites() {
            console.log('[loadFavorites] 함수 시작. isUserLoggedIn() 결과:', isUserLoggedIn());
            if (!loadingMessageDiv || !emptyMessageDiv || !loginRequiredDiv || !favoritesListElement) {
                console.error("[loadFavorites] 필수 DOM 요소 중 일부를 찾을 수 없습니다.");
                return;
            }

            if (!isUserLoggedIn()) {
                loadingMessageDiv.style.display = 'none';
                emptyMessageDiv.style.display = 'none';
                loginRequiredDiv.style.display = 'block';
                favoritesListElement.innerHTML = '';
                return;
            }

            loadingMessageDiv.style.display = 'block';
            emptyMessageDiv.style.display = 'none';
            loginRequiredDiv.style.display = 'none';
            favoritesListElement.innerHTML = '';

            // fetchAndSetInitialFavoritesLocal 함수가 완료되기를 기다립니다.
            // (이 함수는 <head>에서 이미 호출 시도되었을 수 있지만, DOMContentLoaded 이후에 다시 한번
            //  정확한 user_no와 contextPath로 호출하고 완료를 기다리는 것이 안전합니다.)
            // await fetchAndSetInitialFavoritesLocal(); // ⭐ 즐겨찾기 상태를 먼저 가져온 후 목록을 그림

            // 또는, createFavoriteItemHTML에서 항상 최신 전역 Set을 참조하므로,
            // fetchAndSetInitialFavoritesLocal 호출과 loadFavorites API 호출이 병렬로 일어나도
            // 최종적으로 UI에 반영될 때는 정확한 상태를 반영할 수 있습니다.
            // 여기서는 일단 API를 바로 호출합니다.
            console.log(`[loadFavorites] API 호출 전 window.myApp.userFavoriteStationIds 상태:`, Array.from(window.myApp.userFavoriteStationIds || new Set()));


            try {
                console.log(`[내 즐겨찾기] 목록 로드 API 호출 예정. user_no: '${user_no}', contextPath: '${contextPath}'`);
                if (!user_no) { throw new Error("API 호출 전 user_no가 유효하지 않습니다."); }
                if (typeof contextPath !== 'string') { throw new Error("애플리케이션 경로(contextPath)가 유효하지 않습니다."); }

                const response = await fetch(`${contextPath}/favorite/list/details?user_no=${user_no}`);
                if (!response.ok) {
                    const errorText = await response.text().catch(() => `서버 응답 오류 (상태: ${response.status})`);
                    throw new Error(`서버 응답 오류: ${response.status} ${response.statusText} - ${errorText}`);
                }
                
                const favoriteStations = await response.json();
                console.log("[내 즐겨찾기] 로드된 목록:", favoriteStations);

                if (favoriteStations && favoriteStations.length > 0) {
                    let listHtml = "";
                    favoriteStations.forEach(station => {
                        if (station && station.stat_id) {
                            listHtml += createFavoriteItemHTML(station);
                        } else { console.warn("로드된 즐겨찾기 항목 중 유효하지 않은 데이터 발견:", station); }
                    });
                    favoritesListElement.innerHTML = listHtml;
                } else {
                    emptyMessageDiv.style.display = 'block';
                }
            } catch (error) {
                console.error("즐겨찾기 목록 로드 실패 (catch 블록):", error.message);
                favoritesListElement.innerHTML = '<p style="color:red; text-align:center;">즐겨찾기 목록을 불러오는 중 오류가 발생했습니다.</p>';
            } finally {
                loadingMessageDiv.style.display = 'none';
            }
        }

        async function toggleFavoriteOnListPage(statId, buttonElement) {
            if (!isUserLoggedIn()) { alert("로그인이 필요합니다."); return; }
            if (!statId) { console.error("토글할 statId가 없습니다."); return; }

            buttonElement.disabled = true;
            console.log(`[내 즐겨찾기] 토글 시도: user_no=${user_no}, stat_id=${statId}`);
            if (typeof contextPath !== 'string') { /* ... (contextPath 오류 처리) ... */ return; }

            try {
                const response = await fetch(`${contextPath}/favorite/toggle`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ user_no: user_no, stat_id: statId })
                });
                const responseText = await response.text();
                let result;
                try { result = JSON.parse(responseText); console.log("[내 즐겨찾기] 토글 API 응답 (Parsed):", result); }
                catch (e) { console.error("JSON 파싱 오류:", e, "\n응답 텍스트:", responseText); throw new Error("서버 응답 형식이 올바르지 않습니다."); }

                if (response.ok && result && result.status === 'success' && typeof result.favorite === 'boolean') {
                    buttonElement.classList.toggle('active', result.favorite);
                    buttonElement.title = result.favorite ? '즐겨찾기에서 제거' : '즐겨찾기에 추가';

                    if (window.myApp.userFavoriteStationIds instanceof Set) {
                        if (result.favorite) { window.myApp.userFavoriteStationIds.add(statId); }
                        else {
                            window.myApp.userFavoriteStationIds.delete(statId);
                            const itemToRemove = favoritesListElement.querySelector(`.favorite-item[data-stat-id="${statId}"]`);
                            if (itemToRemove) {
                                itemToRemove.remove();
                                if (favoritesListElement.children.length === 0) {
                                    if(emptyMessageDiv) emptyMessageDiv.style.display = 'block';
                                }
                            }
                        }
                    }
                    console.log('[내 즐겨찾기] window.myApp.userFavoriteStationIds 업데이트됨:', Array.from(window.myApp.userFavoriteStationIds || new Set()));
                    if(typeof window.updateFavoriteCountInHeader === 'function') window.updateFavoriteCountInHeader();
                } else {
                    let alertMessage = "즐겨찾기 변경 실패: ";
                    alertMessage += (result && result.message) ? result.message : "서버에서 오류가 발생했습니다.";
                    alert(alertMessage);
                    console.error("[내 즐겨찾기] 즐겨찾기 변경 실패 상세:", result);
                }
            } catch (error) {
                console.error("즐겨찾기 토글 API 또는 처리 중 오류:", error);
                alert("즐겨찾기 변경 중 오류가 발생했습니다: " + error.message);
            } finally {
                buttonElement.disabled = false;
            }
        }

        if (favoritesListElement) {
            favoritesListElement.addEventListener('click', function (event) {
                const target = event.target;
                const listItem = target.closest('.favorite-item'); 
                if (!listItem) return;

                const favoriteBtn = target.closest('.favorite-toggle-btn');
                const viewOnMapBtn = target.closest('.view-on-map-btn');

                const statId = listItem.dataset.statId;
                const lat = listItem.dataset.lat;
                const lng = listItem.dataset.lng;
                let name = listItem.dataset.stnPlace; 
                name = name.replace(/&quot;/g, '"'); 

                if (favoriteBtn) {
                    toggleFavoriteOnListPage(statId, favoriteBtn);
                } else if (viewOnMapBtn) {
                    if (lat && lng && lat !== '-' && lng !== '-') {
                        const encodedName = encodeURIComponent(name);
                        if (typeof contextPath !== 'string') { console.error("지도 보기 링크 생성 실패: contextPath가 없습니다."); return; }
                        window.location.href = `${contextPath}/main?lat=${lat}&lng=${lng}&name=${encodedName}`;
                    } else {
                        alert("지도에서 위치를 표시할 수 없습니다 (좌표 정보 부족).");
                    }
                }
            });
        } else {
            console.error("ID가 'favorite-station-list'인 요소를 찾을 수 없습니다. (DOMContentLoaded 내부)");
        }
        
        // DOM이 준비되면, 전역 즐겨찾기 상태를 먼저 가져온 후, 즐겨찾기 목록을 화면에 표시합니다.
        (async () => {
            // fetchAndSetInitialFavoritesLocal 함수가 <head>에서 이미 호출되었을 수 있으므로,
            // 여기서는 해당 함수의 완료를 기다리거나, 또는 그 함수가 window.myApp.userFavoriteStationIds를
            // 확실히 채웠다는 가정 하에 loadFavorites를 호출합니다.
            // 더 확실한 방법은 fetchAndSetInitialFavoritesLocal이 Promise를 반환하고 여기서 await하는 것입니다.
            // <head>의 fetchAndSetInitialFavoritesLocal은 DOMContentLoaded보다 먼저 실행될 가능성이 높습니다.
            // 따라서, 이 시점에는 어느정도 채워져 있거나, API 호출이 진행 중일 수 있습니다.
            // loadFavorites 내부의 createFavoriteItemHTML에서 실시간으로 window.myApp.userFavoriteStationIds를 참조하므로
            // 초기 버튼 상태가 정확하게 반영될 것입니다.
            if (document.getElementById('favorite-station-list')) {
                 console.log("[DOMContentLoaded] loadFavorites 호출 전, user_no:", user_no, "contextPath:", contextPath);
                 loadFavorites();
            }
        })();

    }); // END DOMContentLoaded
    </script>
</body>
</html>