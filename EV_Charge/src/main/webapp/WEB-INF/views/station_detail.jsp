<%-- station_detail.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- user_no 설정 (페이지 상단 또는 head 태그 내) --%>
<c:if test="${not empty sessionScope.user && not empty sessionScope.user.user_no}">
<script>
    const user_no = parseInt(${sessionScope.user.user_no});
    console.log('[페이지 로드] station_detail.jsp: user_no 설정됨:', user_no);
</script>
</c:if>
<c:if test="${empty sessionScope.user || empty sessionScope.user.user_no}">
<!--<script>-->
<!--    const user_no = null; -->
<!--    console.warn('[페이지 로드] station_detail.jsp: 사용자 로그인되지 않았거나 user_no 없음.');-->
<!--</script>-->
</c:if>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/station_detail.css">

<%-- HTML 구조는 제공해주신 내용과 동일하게 유지 --%>
<div id="station-detail-sidebar" class="station-sidebarA">
    <%-- ... (sidebar-header) ... --%>
    <div class="sidebar-header">
        <div class="sidebar-title"><i class="fas fa-charging-station"></i><h3>충전소 상세 정보</h3></div>
        <div class="sidebar-actions">
            <button id="back-to-list" class="action-btn" title="목록으로"><i class="fas fa-arrow-left"></i></button>
            <button id="close-detail-sidebar" class="action-btn" title="닫기"><i class="fas fa-times"></i></button>
        </div>
    </div>
    
    <div class="sidebar-content">
        <div class="station-detail-container">
            <div id="station_data_hidden" style="display:none;" 
                 data-stat-id="" data-stn-place="" data-stn-addr="" data-lat="" data-lng="">
            </div>
            <div class="detail-section">
                <div class="station-header">
                    <h2 id="station-name" class="station-title"></h2>
                    <button id="toggle-favorite" class="favorite-btn" title="즐겨찾기"><i class="fas fa-star"></i></button>
                </div>
                <div class="station-address-container">
                    <i class="fas fa-map-marker-alt"></i><p id="station-address" class="station-address"></p>
                </div>
                <div class="action-buttons">
                    <button class="action-button primary" onclick="handleNavigateToStation()"><i class="fas fa-directions"></i><span>길찾기</span></button>
                    <button class="action-button secondary" onclick="handleShareStation()"><i class="fas fa-share-alt"></i><span>공유하기</span></button>
                </div>
            </div>
            <%-- 나머지 HTML 구조 생략 --%>
            <div class="detail-section">
                <h3 class="section-title"><i class="fas fa-plug"></i><span>충전기 정보</span><span>충전기 사용 현황</span></h3>
                <div class="charger-info" id="charger-info">
                    <div class="charger-type rapid_div" style="display:none;"><div class="charger-icon fast"><i class="fas fa-bolt"></i></div><div class="charger-details"><h4>급속 충전기</h4><p id="fast-charger-count"><strong id="strong_rapid">0</strong>대<br>사용가능: <strong id="rapid_count">0</strong></p></div></div>
                    <div class="charger-type slow_div" style="display:none;"><div class="charger-icon slow"><i class="fas fa-battery-half"></i></div><div class="charger-details"><h4>완속 충전기</h4><p id="slow-charger-count"><strong id="strong_slow">0</strong>대<br>사용가능: <strong id="slow_count">0</strong></p></div></div>
                </div>
            </div>
            <div class="detail-section">
                <h3 class="section-title"><i class="fas fa-car"></i><span>충전기 타입</span></h3>
                <div id="supported-vehicles" class="supported-vehicles">
                     <div class="charger-type rapid_div" style="display:none;"><div class="charger-icon fast"><i class="fas fa-bolt"></i></div><div class="charger-details"><h4>급속</h4><p class="type_block" id="rapid_type">정보 없음</p></div></div>
                    <div class="charger-type slow_div" style="display:none;"><div class="charger-icon slow"><i class="fas fa-battery-half"></i></div><div class="charger-details"><h4>완속</h4><p class="type_block" id="slow_type">정보 없음</p></div></div>
                </div>
            </div>
            <div class="detail-section">
                <h3 class="section-title"><i class="fas fa-info-circle"></i><span>운영 정보</span></h3>
                <div class="operation-info">
                    <div class="info-item"><div class="info-label">운영 시간</div><div id="operation-hours" class="info-value">정보 없음</div></div>
                    <div class="info-item"><div class="info-label">주차 요금</div><div id="parking_free" class="info-value">정보 없음</div></div>
                    <div class="info-item"><div class="info-label">운영 기관</div><div id="operation-agency" class="info-value">정보 없음</div></div>
                    <div class="info-item"><div class="info-label">연락처</div><div id="contact-number" class="info-value">정보 없음</div></div>
                </div>
            </div>
        </div>
    </div>
    <div class="sidebar-footer">
        <button id="report-issue" class="report-btn"><i class="fas fa-exclamation-triangle"></i><span>오류 신고하기</span></button>
    </div>
</div>

<script>
    // --- 전역 즐겨찾기 상태 관리 ---
    // window.userFavoriteStationIds Set 객체는 다른 JavaScript 파일(예: 공통 스크립트, 메인 페이지 스크립트)에서
    // 페이지 로드 시 또는 로그인 시 한 번 사용자의 전체 즐겨찾기 stat_id 목록으로 초기화되어야 합니다.
    // 이것이 선행되지 않으면, 이 페이지에서는 즐겨찾기 상태를 정확히 반영할 수 없습니다.
    if (typeof window.userFavoriteStationIds === 'undefined') {
        window.userFavoriteStationIds = new Set();
        console.warn("station_detail.jsp: 전역 window.userFavoriteStationIds가 정의되지 않아 새로 생성합니다. " +
                     "실제 즐겨찾기 데이터는 애플리케이션 초기화 시점에 다른 곳에서 `/favorite/status` API를 호출하여 채워져야 합니다.");
        
        // 예시: 애플리케이션 초기화 시점에 호출되어야 할 함수 (실제 구현은 공통 스크립트 등에 위치)
        // async function fetchInitialFavoriteStatus() {
        //     if (typeof user_no !== 'undefined' && user_no !== null && user_no > 0) {
        //         try {
        //             const response = await fetch(`/favorite/status?user_no=${user_no}`);
        //             const data = await response.json();
        //             if (data.status === 'success' && Array.isArray(data.favoriteStationIds)) {
        //                 window.userFavoriteStationIds = new Set(data.favoriteStationIds);
        //                 console.log('전역 즐겨찾기 상태 초기 로드 완료:', Array.from(window.userFavoriteStationIds));
        //                 // 만약 상세 정보가 이미 표시된 상태라면 버튼 업데이트
        //                 if (document.getElementById('station-detail-sidebar').classList.contains('active') && 
        //                     document.getElementById('station_data_hidden').dataset.statId) {
        //                     window.updateDetailFavoriteButtonState();
        //                 }
        //             } else {
        //                 console.warn('전역 즐겨찾기 상태 초기 로드 실패:', data.message);
        //             }
        //         } catch (error) {
        //             console.error('전역 즐겨찾기 상태 초기 로드 중 예외 발생:', error);
        //         }
        //     } else {
        //         console.log("사용자 로그인 상태가 아니거나 user_no가 없어 전역 즐겨찾기를 로드하지 않습니다.");
        //     }
        // }
        // fetchInitialFavoriteStatus(); // 실제로는 DOMContentLoaded 이후 또는 로그인 직후 호출
    }


    document.addEventListener('DOMContentLoaded', function() {
		console.log('[DOMContentLoaded] station_detail.jsp 시작');
		console.log('[DOMContentLoaded] 현재 user_no:', (typeof user_no !== 'undefined' ? user_no : '정의되지 않음'));
		console.log('[DOMContentLoaded] 현재 window.userFavoriteStationIds:', (window.userFavoriteStationIds instanceof Set ? Array.from(window.userFavoriteStationIds) : window.userFavoriteStationIds ));

        const sidebar = document.getElementById('station-detail-sidebar');
        const closeSidebarBtn = document.getElementById('close-detail-sidebar');
        const backToListBtn = document.getElementById('back-to-list');
        const favoriteBtn = document.getElementById('toggle-favorite');
        const stationDataHiddenDiv = document.getElementById('station_data_hidden');

        function isUserLoggedIn() {
            return typeof user_no !== 'undefined' && user_no !== null && !isNaN(user_no) && user_no > 0;
        }

        window.openDetailSidebar = function() {
            sidebar.classList.add('active');
            // 상세 정보 내용은 updateStationDetailTwo 함수에서 채워지고, 
            // 그 안에서 updateDetailFavoriteButtonState가 호출되어 버튼 상태를 설정합니다.
        };
        
        closeSidebarBtn.addEventListener('click', function() {
            sidebar.classList.remove('active');
        });
        
        backToListBtn.addEventListener('click', function() {
            sidebar.classList.remove('active');
            if (window.openSidebar) {
                window.openSidebar();
            }
        });
        
        favoriteBtn.addEventListener('click', async function() {
            if (!isUserLoggedIn()) {
                alert("로그인이 필요합니다.");
                return;
            }

            const currentStatId = stationDataHiddenDiv.dataset.statId;
            if (!currentStatId || currentStatId.trim() === "") {
                console.error("[Frontend] 즐겨찾기 토글 실패: 유효한 충전소 ID (stat_id)가 없습니다.");
                alert("충전소 정보가 올바르지 않아 즐겨찾기를 처리할 수 없습니다.");
                return;
            }

            console.log(`[Frontend] 즐겨찾기 토글 API 호출 시도: user_no=${user_no}, stat_id='${currentStatId}'`);
            this.disabled = true;

            try {
                const response = await fetch('/favorite/toggle', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ 
                        user_no: user_no, 
                        stat_id: currentStatId
                    })
                });
                
                const responseText = await response.text();
                console.log('[Frontend] 서버 원본 응답 (Text):', responseText);

                let result;
                try {
                    result = JSON.parse(responseText);
                } catch (parseError) {
                    console.error('[Frontend] 서버 응답 JSON 파싱 오류:', parseError, "\n응답 텍스트:", responseText);
                    alert(`서버 응답 처리 오류: 응답 형식이 올바르지 않습니다. (상태: ${response.status})`);
                    this.disabled = false;
                    return;
                }
                
                console.log('[Frontend] 즐겨찾기 토글 API 응답 (Parsed JSON):', result);

                if (response.ok && result && result.status === 'success' && typeof result.favorite === 'boolean') { // **수정: isFavorite -> favorite**
                    this.classList.toggle('active', result.favorite); // **수정: isFavorite -> favorite**
                    console.log(`[Frontend] 버튼 'active' 클래스 최종 설정: ${result.favorite}. 현재 버튼 클래스: `+this.className);

                    if (result.favorite) { // **수정: isFavorite -> favorite**
                        window.userFavoriteStationIds.add(currentStatId);
                    } else {
                        window.userFavoriteStationIds.delete(currentStatId);
                    }
                    console.log('[Frontend] window.userFavoriteStationIds 업데이트됨:', Array.from(window.userFavoriteStationIds));
                    
                    if (window.refreshFavoriteStatusInListView) { 
                        window.refreshFavoriteStatusInListView(currentStatId, result.favorite); // **수정: isFavorite -> favorite**
                    }
                } else {
                    let alertMessage = "즐겨찾기 처리 중 문제가 발생했습니다: ";
                    if (result && result.message) {
                        alertMessage += result.message;
                    } else if (!response.ok) {
                        alertMessage += `서버 통신 오류 (상태 코드: ${response.status}).`;
                    } else if (result && result.status !== 'success') {
                        alertMessage += `처리 실패 (서버 메시지: ${result.message || '상세 정보 없음'}).`;
                    } else {
                        alertMessage += "알 수 없는 오류입니다. (서버 응답 형식 또는 내용을 확인해주세요)";
                    }
                    alert(alertMessage);
                    console.error("[Frontend] 즐겨찾기 처리 실패 상세 정보:", {
                        responseOk: response.ok, httpStatus: response.status, resultReceived: !!result,
                        resultStatus: result ? result.status : 'N/A', 
                        resultFavoriteType: result ? typeof result.favorite : 'N/A', // **수정: isFavorite -> favorite**
                        fullResult: result
                    });
                    if (result && typeof result.favorite === 'boolean') { // **수정: isFavorite -> favorite**
                         this.classList.toggle('active', result.favorite); 
                         console.log(`[Frontend] 처리 실패 후 버튼 상태 동기화 (서버 응답 기준): ${result.favorite}`);
                    }
                }
            } catch (err) {
                console.error('[Frontend] 즐겨찾기 요청/처리 중 예외 발생:', err);
                alert(`클라이언트 측 오류가 발생했습니다: ${err.message}.`);
            } finally {
                this.disabled = false;
            }
        });

        // 즐겨찾기 버튼 상태를 현재 정보 기준으로 업데이트 하는 함수
        window.updateDetailFavoriteButtonState = function() {
            console.log("updateDetailFavoriteButtonState 호출됨");
            const currentFavoriteBtn = document.getElementById('toggle-favorite'); 
            const currentHiddenData = document.getElementById('station_data_hidden');

            if (!isUserLoggedIn()) {
                currentFavoriteBtn.classList.remove('active');
                currentFavoriteBtn.style.display = 'none';
                console.log("사용자 로그인 안됨, 즐겨찾기 버튼 숨김.");
                return;
            }
            currentFavoriteBtn.style.display = '';

            const currentDetailStatId = currentHiddenData.dataset.statId;
            console.log(`현재 상세 정보 stat_id: '${currentDetailStatId}' (updateDetailFavoriteButtonState 내부)`);
            
            // window.userFavoriteStationIds가 Set이고, 내용이 있는지 확인
            if (window.userFavoriteStationIds instanceof Set) {
                console.log(`현재 window.userFavoriteStationIds 내용:`, Array.from(window.userFavoriteStationIds));
                if (currentDetailStatId && currentDetailStatId.trim() !== "") {
                    if (window.userFavoriteStationIds.has(currentDetailStatId)) {
                        currentFavoriteBtn.classList.add('active');
                        console.log(`버튼 상태 업데이트: 즐겨찾기 추가됨 (active) - ID: ${currentDetailStatId}`);
                    } else {
                        currentFavoriteBtn.classList.remove('active');
                        console.log(`버튼 상태 업데이트: 즐겨찾기 안됨 (inactive) - ID: ${currentDetailStatId}`);
                    }
                } else {
                    currentFavoriteBtn.classList.remove('active');
                    if (!currentDetailStatId || currentDetailStatId.trim() === "") console.log("updateDetailFavoriteButtonState: 유효한 stat_id가 없어 버튼을 비활성 상태로 설정합니다.");
                }
            } else {
                console.warn("updateDetailFavoriteButtonState: window.userFavoriteStationIds가 Set 객체가 아닙니다. 버튼 상태를 정확히 설정할 수 없습니다.");
                currentFavoriteBtn.classList.remove('active'); // 안전하게 비활성 상태로
            }
        };
    }); // END DOMContentLoaded
    
    function handleNavigateToStation() {
        // ... (이전과 동일)
        const stationData = document.getElementById('station_data_hidden');
        const lat = stationData.dataset.lat;
        const lng = stationData.dataset.lng;
        
        if (lat && lng && lat.trim() !== "" && lng.trim() !== "") {
            const url = `https://map.kakao.com/link/to,목적지,${lat},${lng}`;
            window.open(url, '_blank');
        } else {
            alert("위치 정보가 없어 길찾기를 실행할 수 없습니다.");
            console.warn("NavigateToStation: lat 또는 lng 정보 부족", {lat, lng});
        }
    }
    
    function handleShareStation() {
        // ... (이전과 동일)
        const stationData = document.getElementById('station_data_hidden');
        const stationName = stationData.dataset.stnPlace;
        const stationAddress = stationData.dataset.stnAddr;
        
        if (!stationName || stationName.trim() === "") {
            alert("공유할 충전소 정보가 부족합니다.");
            return;
        }

        const shareText = `EV 충전소 정보: ${stationName}\n주소: ${stationAddress || '주소 정보 없음'}`;
        if (navigator.share) {
            navigator.share({ title: stationName, text: shareText, })
                .then(() => console.log('공유 성공'))
                .catch(err => console.error('공유 API 실패:', err));
        } else {
            navigator.clipboard.writeText(shareText)
                .then(() => alert("충전소 정보가 클립보드에 복사되었습니다."))
                .catch(err => {
                    alert("공유하기 기능을 지원하지 않거나 클립보드 복사에 실패했습니다.");
                    console.error('클립보드 복사 실패:', err);
                });
        }
    }
	
	function updateStationDetailTwo(markerData) {
	    console.log("updateStationDetailTwo 호출됨, markerData:", markerData);
	    const stationDataHiddenDiv = document.getElementById('station_data_hidden');

	    if (!markerData || !markerData.chargerList || markerData.chargerList.length === 0) {
	        console.error("updateStationDetailTwo: 유효한 충전기 정보(chargerList)가 없습니다.");
	        document.getElementById("station-name").textContent = "정보 조회 실패";
	        stationDataHiddenDiv.dataset.statId = ""; 
	        if (window.updateDetailFavoriteButtonState) window.updateDetailFavoriteButtonState();
	        return;
	    }

	    const first = markerData.chargerList[0];

	    if (!first || !first.stat_id || first.stat_id.trim() === "") {
	        console.error("updateStationDetailTwo: 전달된 데이터에 유효한 stat_id가 없습니다!", first);
	        document.getElementById("station-name").textContent = "충전소 ID 오류";
	        stationDataHiddenDiv.dataset.statId = ""; 
	        if (window.updateDetailFavoriteButtonState) window.updateDetailFavoriteButtonState();
	        return;
	    }

	    stationDataHiddenDiv.dataset.statId = first.stat_id;
	    stationDataHiddenDiv.dataset.stnPlace = first.stat_name || "";
	    stationDataHiddenDiv.dataset.stnAddr = first.addr || "";
	    stationDataHiddenDiv.dataset.lat = first.lat || "";
	    stationDataHiddenDiv.dataset.lng = first.lng || "";
	    
	    console.log(`updateStationDetailTwo: 상세 정보 설정 시작, stat_id = '${first.stat_id}'`);

	    // (중요) stat_id가 설정된 후, 그리고 stat_data API 호출 전에 버튼 상태를 먼저 업데이트
	    if (window.updateDetailFavoriteButtonState) {
	        window.updateDetailFavoriteButtonState();
	    }

	    fetch("stat_data", { 
	         method: "POST",
	         headers: {"Content-Type":"application/json"},
	         body: JSON.stringify({stat_id : first.stat_id})
	    })
	    .then(response => {
	        if (!response.ok) {
	            return response.text().then(text => { 
	                throw new Error(`stat_data API 오류: ${response.status} ${response.statusText} - ${text}`);
	            });
	        }
	        return response.json();
	    })
	    .then(data =>{
	        console.log("stat_data API 응답 수신:", data);
	        let rapid_count_available = (data && data.rapid_stat_three !== undefined) ? data.rapid_stat_three : 0; 
	        let slow_count_available = (data && data.slow_stat_three !== undefined) ? data.slow_stat_three : 0;   
	    
	        document.getElementById("station-name").textContent = first.stat_name || "정보 없음";
	        let addressHtml = first.addr || "주소 정보 없음";
	        if (first.addr_detail && first.addr_detail.toLowerCase() !== "null" && first.addr_detail.trim() !== "") {
	            addressHtml += "<br>" + first.addr_detail;
	        }
	        if (first.location && first.location.toLowerCase() !== "null" && first.location.trim() !== "" && 
	            (!first.addr_detail || first.addr_detail.toLowerCase() === "null" || first.addr_detail.trim() === "" || first.addr_detail !== first.location)) {
	            addressHtml += "<br>" + first.location;
	        }
	        document.getElementById("station-address").innerHTML = addressHtml;
	        
	        const chger_type_map = { /* ... 이전과 동일 ... */
                "01": "B타입(5핀)", "02": "C타입(5핀)", "03": "BC타입(5핀)", "04": "BC타입(7핀)",
                "05": "DC차데모", "06": "AC3상", "07": "DC콤보", "08": "DC차데모+DC콤보",
                "09": "DC차데모+AC3상", "10": "DC차데모+DC콤보+AC3상"
            };
	        var rapid_c_total = 0; 
	        var slow_c_total = 0;  
	        let charger_types_slow_set = new Set();
	        let charger_types_rapid_set = new Set();

	        chargerList.forEach(charger => {
	            var output = parseInt(charger.output, 10); 
	            var chger_type_code = charger.chger_type;   
	            const type_desc = chger_type_map[chger_type_code] || chger_type_code; 
	            if (!isNaN(output)) {
	                if(output > 0 && output < 50){ slow_c_total++; if (type_desc) charger_types_slow_set.add(type_desc); } 
	                else if (output >= 50){ rapid_c_total++; if (type_desc) charger_types_rapid_set.add(type_desc); }
	            }
	        });
	        
	        const rapidInfoDivs = document.querySelectorAll(".rapid_div"); // 여러 곳에 있을 수 있으므로 querySelectorAll 사용
            const slowInfoDivs = document.querySelectorAll(".slow_div");

            rapidInfoDivs.forEach(div => div.style.display = rapid_c_total > 0 ? "" : "none");
            slowInfoDivs.forEach(div => div.style.display = slow_c_total > 0 ? "" : "none");
	        
	        document.getElementById("strong_rapid").textContent = rapid_c_total;
	        document.getElementById("rapid_count").textContent = rapid_count_available;
	        document.getElementById("strong_slow").textContent = slow_c_total;
	        document.getElementById("slow_count").textContent = slow_count_available;
	        
	        document.getElementById("rapid_type").textContent = Array.from(charger_types_rapid_set).join(", ") || (rapid_c_total > 0 ? "타입 정보 없음" : "");
	        document.getElementById("slow_type").textContent = Array.from(charger_types_slow_set).join(", ") || (slow_c_total > 0 ? "타입 정보 없음" : "");

	        let parking_free_text = "정보 없음";
	        if (first.parking_free === 'Y') parking_free_text = "무료";
	        else if (first.parking_free === 'N') parking_free_text = "유료";
	        
	        document.getElementById("operation-hours").textContent = first.use_time || "정보 없음";
	        document.getElementById("parking_free").textContent = parking_free_text;
	        document.getElementById("operation-agency").textContent = first.busi_nm || "정보 없음";
	        document.getElementById("contact-number").textContent = first.busi_call || "정보 없음";

	        // 모든 UI 업데이트 후 즐겨찾기 버튼 상태 다시 한번 최종 확인
	        if (window.updateDetailFavoriteButtonState) {
	            window.updateDetailFavoriteButtonState();
	        }
	    })
	    .catch(error => {
	        console.error("stat_data API 호출 또는 데이터 처리 중 오류:", error.message);
	        document.getElementById("rapid_count").textContent = "확인불가";
	        document.getElementById("slow_count").textContent = "확인불가";
	        // 오류 발생 시에도 즐겨찾기 버튼 상태는 업데이트 시도
	        if (window.updateDetailFavoriteButtonState) {
	            window.updateDetailFavoriteButtonState();
	        }
	    });
	}
</script>