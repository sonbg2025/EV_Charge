<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="${pageContext.request.contextPath}/js/jquery.js"></script>
<jsp:include page="/WEB-INF/views/header.jsp" />
<script>
    window.myApp = window.myApp || {};
    window.myApp.contextPath = "<%= request.getContextPath() %>";
    window.myApp.userNo = "<%= session.getAttribute("user_no") != null ? session.getAttribute("user_no") : "" %>";
</script>


<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 즐겨찾는 충전소</title>

    <%-- jQuery는 header.jsp 또는 여기서 단 한 번, 가장 먼저 로드되어야 함 --%>
    <%-- Font Awesome도 header.jsp 또는 여기서 단 한 번, 가장 먼저 로드 --%>
    <%-- 예시: <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"> --%>

    <style>
        /* 기본 스타일 */
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; background-color: #f8f9fa; color: #343a40; line-height: 1.6; }
        .my-favorites-container { max-width: 860px; margin: 30px auto; background-color: #ffffff; padding: 25px 35px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .favorites-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #e9ecef; padding-bottom: 20px; margin-bottom: 25px; }
        .favorites-header h1 { margin: 0; font-size: 2em; color: #007bff; font-weight: 600; }
        .favorites-header h1 .fa-star { color: #ffc107; margin-right: 10px; }
        .back-to-map-btn { display: inline-flex; align-items: center; padding: 10px 18px; background-color: #6c757d; color: white; text-decoration: none; border-radius: 6px; font-size: 0.95em; transition: background-color 0.2s ease; }
        .back-to-map-btn:hover { background-color: #5a6268; }
        .back-to-map-btn .fa-map-marked-alt { margin-right: 7px; }
        .message-area { text-align: center; padding: 30px 20px; color: #6c757d; font-size: 1.1em; border: 1px dashed #ced4da; border-radius: 6px; background-color: #f8f9fa; margin-top: 20px; }
        .message-area i { margin-right: 8px; font-size: 1.3em; vertical-align: middle; }
        .message-area a { color: #007bff; text-decoration: none; font-weight: 500; }
        .message-area a:hover { text-decoration: underline; }
        .station-list-ul { list-style-type: none; padding: 0; margin: 0; }
        .favorite-item { display: flex; justify-content: space-between; align-items: flex-start; padding: 20px 0; border-bottom: 1px solid #dee2e6; }
        .favorite-item:last-child { border-bottom: none; }
        .station-details { flex-grow: 1; padding-right: 20px; }
        .station-details h3 { margin: 0 0 8px 0; font-size: 1.35em; color: #212529; font-weight: 600; }
        .station-details p { margin: 4px 0; font-size: 0.95em; color: #495057; }
        .station-details .station-address i { margin-right: 6px; color: #007bff; }
        .station-details .station-coords { font-size: 0.85em; color: #6c757d; }
        .station-actions { display: flex; flex-shrink: 0; align-items: center; }
        .station-actions button { background-color: transparent; border: 1px solid #ced4da; border-radius: 50%; width: 42px; height: 42px; cursor: pointer; font-size: 1.25em; color: #adb5bd; margin-left: 10px; transition: all 0.2s ease-in-out; display: flex; justify-content: center; align-items: center; }
        .station-actions button:hover { background-color: #e9ecef; color: #495057; }
        .station-actions .favorite-toggle-btn.active .fa-star { color: #ffc107; }
        .station-actions .favorite-toggle-btn:hover.active .fa-star { color: #e0a800; }
        .station-actions .view-on-map-btn .fa-search-location { color: #28a745; }
        .station-actions .view-on-map-btn:hover .fa-search-location { color: #1e7e34; }
    </style>

    <script>
        // 이 페이지에서 사용할 전역 변수들을 참조합니다.
        // 이 변수들은 main.jsp 또는 header.jsp에서 이미 설정되었다고 가정합니다.
        // window.myApp 네임스페이스 사용 (충돌 방지)
        window.myApp = window.myApp || {}; 
        const user_no = window.myApp.userNo; // main.jsp 등에서 설정된 전역 user_no
        const contextPath = window.myApp.contextPath || "${pageContext.request.contextPath}"; // main.jsp에서 설정 안됐을 경우 대비

        // window.myApp.userFavoriteStationIds는 main.jsp 또는 공통 스크립트에서 API 호출로 채워져야 합니다.
        if (typeof window.myApp.userFavoriteStationIds === 'undefined') {
            window.myApp.userFavoriteStationIds = new Set();
            console.warn("my_favorites_list.jsp: 전역 window.myApp.userFavoriteStationIds가 없어 새로 생성합니다. " +
                         "main.jsp 또는 공통 초기화 로직에서 API를 통해 이 Set을 채워야 합니다.");
        }
        console.log('[내 즐겨찾기 페이지] 스크립트 시작. user_no:', user_no, 'contextPath:', contextPath);
        console.log('[내 즐겨찾기 페이지] 초기 window.myApp.userFavoriteStationIds:', Array.from(window.myApp.userFavoriteStationIds));
    </script>
</head>
<body>
    <%-- header.jsp는 body 시작 직후에 오는 것이 일반적입니다. --%>
    <%-- <jsp:include page="/WEB-INF/views/header.jsp" /> --%>

    <div class="my-favorites-container">
        <header class="favorites-header">
            <h1><i class="fas fa-star"></i> 내 즐겨찾는 충전소</h1>
            <a href="${pageContext.request.contextPath}/main" class="back-to-map-btn">
                <i class="fas fa-map-marked-alt"></i> 지도로 돌아가기
            </a>
        </header>

        <main id="favorites-list-content">
            <div class="message-area loading-favorites">
                <p><i class="fas fa-spinner fa-spin"></i> 즐겨찾기 목록을 불러오는 중입니다...</p>
            </div>
            <div class="message-area empty-favorites" style="display:none;">
                <p><i class="fas fa-info-circle"></i> 즐겨찾기한 충전소가 없습니다.</p>
                <p>지도에서 충전소를 검색하고 <i class="fas fa-star"></i> 아이콘을 눌러 즐겨찾기에 추가해보세요.</p>
            </div>
            <div class="message-area login-required" style="display:none;">
                <p><i class="fas fa-exclamation-triangle"></i> 로그인이 필요한 서비스입니다.</p>
                <p><a href="${pageContext.request.contextPath}/login">로그인 페이지로 이동</a></p>
            </div>
            <ul id="favorite-station-list" class="station-list-ul"></ul>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // 전역 변수를 이 스코프에서 사용하기 쉽게 다시 할당 (선택 사항, window.myApp.userNo 직접 사용해도 됨)
            // const user_no = window.myApp.userNo; // 이미 상단 스크립트에서 const user_no로 선언됨
            // const contextPath = window.myApp.contextPath;

            console.log('[내 즐겨찾기 - DOMContentLoaded] user_no:', user_no);
            console.log('[내 즐겨찾기 - DOMContentLoaded] contextPath:', contextPath);
            console.log('[내 즐겨찾기 - DOMContentLoaded] window.myApp.userFavoriteStationIds:', Array.from(window.myApp.userFavoriteStationIds));

            const favoritesListElement = document.getElementById('favorite-station-list');
            const loadingMessageDiv = document.querySelector('.loading-favorites');
            const emptyMessageDiv = document.querySelector('.empty-favorites');
            const loginRequiredDiv = document.querySelector('.login-required');

            function isUserLoggedIn() {
                return typeof user_no === 'number' && !isNaN(user_no) && user_no > 0;
            }

            function createFavoriteItemHTML(station) {
                const currentFavorites = window.myApp.userFavoriteStationIds || new Set(); // 전역 Set 참조
                const isActive = currentFavorites.has(station.stat_id);
                
                const stationName = station.stn_place || '이름 정보 없음';
                const stationAddress = station.stn_addr || '주소 정보 없음';
                const stationLat = station.evse_location_latitude || '-';
                const stationLng = station.evse_location_longitude || '-';
                const stationNameForDataAttr = stationName.replace(/"/g, '&quot;');

                return `
                    <li class="favorite-item" 
                        data-stat-id="${station.stat_id}" 
                        data-lat="${stationLat}" 
                        data-lng="${stationLng}"
                        data-stn-place="${stationNameForDataAttr}">
                        <div class="station-details">
                            <h3 class="station-name">${stationName}</h3>
                            <p class="station-address"><i class="fas fa-map-marker-alt"></i> ${stationAddress}</p>
                            <p class="station-coords">
                                위도: ${stationLat}, 
                                경도: ${stationLng}
                            </p>
                        </div>
                        <div class="station-actions">
                            <button class="favorite-toggle-btn ${isActive ? 'active' : ''}" title="${isActive ? '즐겨찾기에서 제거' : '즐겨찾기에 추가'}">
                                <i class="fas fa-star"></i>
                            </button>
                            <button class="view-on-map-btn" title="지도에서 보기">
                                <i class="fas fa-search-location"></i>
                            </button>
                        </div>
                    </li>
                `;
            }

           /* async function loadFavorites() {
                console.log('[loadFavorites] 함수 시작. isUserLoggedIn() 결과:', isUserLoggedIn());
                if (!isUserLoggedIn()) {
                    if (loadingMessageDiv) loadingMessageDiv.style.display = 'none';
                    if (emptyMessageDiv) emptyMessageDiv.style.display = 'none';
                    if (loginRequiredDiv) loginRequiredDiv.style.display = 'block';
                    if (favoritesListElement) favoritesListElement.innerHTML = '';
                    return;
                }

                if (loadingMessageDiv) loadingMessageDiv.style.display = 'block';
                if (emptyMessageDiv) emptyMessageDiv.style.display = 'none';
                if (loginRequiredDiv) loginRequiredDiv.style.display = 'none';
                if (favoritesListElement) favoritesListElement.innerHTML = '';

                try {
                    console.log(`[내 즐겨찾기] 목록 로드 API 호출 예정. user_no: '${user_no}'`);
                    if (!user_no) { 
                        throw new Error("API 호출 전 user_no가 유효하지 않습니다. (loadFavorites 내부)");
                    }
                    if (!contextPath) {
                        console.error("[loadFavorites] contextPath가 유효하지 않아 API 호출 불가!", contextPath);
                        throw new Error("애플리케이션 경로(contextPath)를 가져올 수 없습니다.");
                    }
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
                            } else {
                                console.warn("로드된 즐겨찾기 항목 중 유효하지 않은 데이터 발견:", station);
                            }
                        });
                        if (favoritesListElement) favoritesListElement.innerHTML = listHtml;
                    } else {
                        if (emptyMessageDiv) emptyMessageDiv.style.display = 'block';
                    }
                } catch (error) {
                    console.error("즐겨찾기 목록 로드 실패 (catch 블록):", error.message);
                    if (favoritesListElement) favoritesListElement.innerHTML = '<p style="color:red; text-align:center;">즐겨찾기 목록을 불러오는 중 오류가 발생했습니다.</p>';
                } finally {
                    if (loadingMessageDiv) loadingMessageDiv.style.display = 'none';
                }
            }
			*/
			function loadFavorites() {
			    const userNo = window.myApp.userNo;
			    const contextPath = window.myApp.contextPath;

			    console.log("[loadFavorites] 함수 시작. user_no:", userNo);
			    
			    if (!contextPath) {
			        console.error("[loadFavorites] contextPath가 유효하지 않아 API 호출 불가!");
			        return;
			    }

			    if (!userNo) {
			        console.error("[loadFavorites] user_no가 유효하지 않아 API 호출 불가!");
			        return;
			    }

			    const url = `${contextPath}/favorites/list?user_no=${userNo}`;
			    console.log("[내 즐겨찾기] 목록 로드 API 호출:", url);

			    fetch(url)
			        .then(response => response.json())
			        .then(data => {
			            console.log("[내 즐겨찾기] 서버 응답:", data);
			            // 즐겨찾기 렌더링 로직
			        })
			        .catch(error => {
			            console.error("[내 즐겨찾기] 목록 로드 실패 (catch 블록):", error.message);
			        });
			}


            async function toggleFavoriteOnListPage(statId, buttonElement) {
                if (!isUserLoggedIn()) { alert("로그인이 필요합니다."); return; }
                if (!statId) { console.error("토글할 statId가 없습니다."); return; }

                buttonElement.disabled = true;
                console.log(`[내 즐겨찾기] 토글 시도: user_no=${user_no}, stat_id=${statId}`);
                if (!contextPath) {
                    console.error("[toggleFavoriteOnListPage] contextPath가 유효하지 않아 API 호출 불가!");
                    alert("오류: 애플리케이션 경로를 찾을 수 없습니다.");
                    buttonElement.disabled = false;
                    return;
                }

                try {
                    const response = await fetch(`${contextPath}/favorite/toggle`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ user_no: user_no, stat_id: statId })
                    });
                    
                    const responseText = await response.text();
                    let result;
                    try { 
                        result = JSON.parse(responseText); 
                        console.log("[내 즐겨찾기] 토글 API 응답 (Parsed):", result);
                    } catch (e) { 
                        console.error("JSON 파싱 오류:", e, "\n응답 텍스트:", responseText);
                        throw new Error("서버 응답 형식이 올바르지 않습니다.");
                    }

                    if (response.ok && result && result.status === 'success' && typeof result.favorite === 'boolean') {
                        buttonElement.classList.toggle('active', result.favorite);
                        buttonElement.title = result.favorite ? '즐겨찾기에서 제거' : '즐겨찾기에 추가';

                        if (window.myApp.userFavoriteStationIds instanceof Set) { // 전역 Set 참조
                            if (result.favorite) { 
                                window.myApp.userFavoriteStationIds.add(statId);
                            } else {
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

            if (favoritesListElement) { // favoritesListElement가 실제로 존재하는지 확인 후 이벤트 리스너 추가
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
                            if (!contextPath) { console.error("지도 보기 링크 생성 실패: contextPath가 없습니다."); return; }
                            window.location.href = `${contextPath}/main?lat=${lat}&lng=${lng}&name=${encodedName}`;
                        } else {
                            alert("지도에서 위치를 표시할 수 없습니다 (좌표 정보 부족).");
                        }
                    }
                });
            } else {
                console.error("favoritesListElement를 찾을 수 없습니다.");
            }
            
            // DOM이 준비되면 즐겨찾기 목록을 로드합니다.
            // window.myApp.userFavoriteStationIds가 <head>의 스크립트에서 비동기적으로 채워질 수 있으므로,
            // loadFavorites는 그 작업이 완료된 후에 호출되는 것이 가장 이상적입니다.
            // 간단하게는 setTimeout으로 약간의 지연을 주거나, 
            // fetchAndSetInitialFavorites가 Promise를 반환하게 하여 .then(loadFavorites)를 사용합니다.
            // 현재는 DOMContentLoaded 후 바로 호출하고, createFavoriteItemHTML에서 최신 Set을 참조합니다.
            // 만약 fetchAndSetInitialFavorites가 아직 완료되지 않았다면, 버튼 상태가 나중에 한번 더 업데이트 될 수 있습니다.
            
            // fetchAndSetInitialFavorites의 완료를 기다리는 더 나은 방법:
            // 1. fetchAndSetInitialFavorites가 Promise를 반환하도록 수정
            // 2. Promise.all() 또는 해당 Promise.then() 내에서 loadFavorites() 호출
            // 여기서는 간단하게, 만약 window.myApp.userFavoriteStationIds를 채우는 API 호출이 아직 안 끝났을 수 있으므로,
            // 약간의 지연 후 또는 API 완료 후 loadFavorites를 호출하는 것을 고려해야 합니다.
            // 지금은 즉시 호출합니다.
            if (document.getElementById('favorite-station-list')) { // 페이지에 목록 요소가 있을 때만 로드
                 loadFavorites();
            }

        }); // END DOMContentLoaded
    </script>
</body>
</html>