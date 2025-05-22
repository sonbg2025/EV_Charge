<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<script src="${pageContext.request.contextPath}/js/jquery.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${pageTitle != null ? pageTitle : '나의 즐겨찾기'}"/> - EV Charge</title>
    <%-- 공통 CSS 및 Font Awesome --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
    <%-- 헤더 포함 --%>
    <jsp:include page="/WEB-INF/views/header.jsp" />

    <main class="favorites-container">
        <h1><i class="fas fa-heart" style="color: #e74c3c;"></i> 나의 즐겨찾기</h1>

        <c:if test="${not empty errorMessage}">
            <p class="error-message"><c:out value="${errorMessage}"/></p>
        </c:if>

        <c:choose>
            <c:when test="${not empty favoritesList}">
                <ul class="favorite-items-grid">
                    <c:forEach var="fav" items="${favoritesList}">
                        <li class="favorite-item-card" id="fav-item-${fn:escapeXml(fav.stat_id)}">
                            <div class="favorite-card-header">
                                <%-- 
                                 FavoriteDTO에 stat_name (충전소 이름) 필드가 없으므로, stat_id를 표시합니다.
                                 추후 FavoriteDTO를 수정하여 stat_name을 포함시키고 백엔드에서 채워주면
                                 fav.stat_name으로 충전소 이름을 표시할 수 있습니다.
                                --%>
                                <h3 class="station-name">충전소 ID: <c:out value="${fav.stat_id}"/></h3>
                                <%-- 예: <c:if test="${not empty fav.stat_name}"><h3 class="station-name"><c:out value="${fav.stat_name}"/></h3></c:if> --%>
                            </div>
                            <div class="favorite-card-body">
                                <p class="address">
                                    <i class="fas fa-map-marker-alt"></i>
                                    <c:out value="${fav.addr}"/>
                                    <c:if test="${not empty fav.addr_detail && fav.addr_detail ne 'null'}">
                                        <br/><c:out value="${fav.addr_detail}"/>
                                    </c:if>
                                    <c:if test="${not empty fav.location && fav.location ne 'null' && fav.location ne fav.addr_detail}">
                                        <br/>(<c:out value="${fav.location}"/>)
                                    </c:if>
                                </p>
                                <p class="coordinates" style="display:none;">
                                    위도: <c:out value="${fav.lat}"/>, 경도: <c:out value="${fav.lng}"/>
                                </p>
                            </div>
                            <div class="favorite-card-actions">
                                <a href="${pageContext.request.contextPath}/main?lat=${fav.lat}&lng=${fav.lng}&statId=${fn:escapeXml(fav.stat_id)}&openDetail=true" class="action-btn view-map-btn">
                                    <i class="fas fa-map-marked-alt"></i> 지도에서 보기
                                </a>
                                <button class="action-btn remove-fav-btn" 
                                        data-stat-id="${fn:escapeXml(fav.stat_id)}"
                                        data-user-no="${fav.user_no}"
                                        data-addr="${fn:escapeXml(fav.addr)}"
                                        data-addr-detail="${fn:escapeXml(fav.addr_detail)}"
                                        data-location="${fn:escapeXml(fav.location)}"
                                        data-lat="${fav.lat}"
                                        data-lng="${fav.lng}">
                                    <i class="fas fa-trash-alt"></i> 삭제
                                </button>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </c:when>
            <c:otherwise>
                <c:if test="${empty errorMessage}"> <%-- 오류 메시지가 없을 때만 "없음" 메시지 표시 --%>
                    <p class="no-favorites-info">즐겨찾기한 충전소가 없습니다. <br/>지도에서 충전소를 찾아 <i class="fas fa-star"></i> 또는 <i class="fas fa-heart"></i> 아이콘을 클릭하여 즐겨찾기에 추가해보세요!</p>
                </c:if>
            </c:otherwise>
        </c:choose>
    </main>

    <%-- 푸터 포함 (있다면) --%>
    <%-- <jsp:include page="/WEB-INF/views/footer.jsp" /> --%>

    <script>
        // main.jsp에서 설정된 window.APP_USER_NO와 window.myApp.contextPath를 사용합니다.
        // window.userFavoriteStationIds (Set)도 main.jsp에서 세션 기반으로 초기화되었다고 가정합니다.

        document.addEventListener('DOMContentLoaded', function() {
            const removeButtons = document.querySelectorAll('.remove-fav-btn');
            removeButtons.forEach(button => {
                button.addEventListener('click', function() {
                    const statId = this.dataset.statId;
                    const userNoFromData = parseInt(this.dataset.userNo); // 즐겨찾기 항목의 소유자 user_no

                    if (!window.APP_USER_NO) {
                        alert("로그인이 필요합니다.");
                        window.location.href = (window.myApp && window.myApp.contextPath ? window.myApp.contextPath : '') + '/login';
                        return;
                    }
                    
                    // 현재 로그인한 사용자가 이 즐겨찾기의 소유자인지 확인 (보안 강화)
                    if (window.APP_USER_NO !== userNoFromData) {
                        alert("잘못된 접근입니다. 본인의 즐겨찾기만 삭제할 수 있습니다.");
                        return;
                    }

                    if (confirm("이 충전소를 즐겨찾기에서 삭제하시겠습니까?")) {
                        const payload = {
                            user_no: window.APP_USER_NO, // 현재 로그인한 사용자
                            stat_id: statId,
                            // toggle API가 삭제 시에도 모든 필드를 요구하지 않을 수 있지만,
                            // 추가 로직과 일관성을 위해 또는 만약을 위해 전달합니다.
                            // FavoriteDTO에 있는 모든 정보를 전달하는 것이 안전할 수 있습니다.
                            addr: this.dataset.addr,
                            addr_detail: this.dataset.addrDetail === 'null' ? null : this.dataset.addrDetail,
                            location: this.dataset.location === 'null' ? null : this.dataset.location,
                            lat: parseFloat(this.dataset.lat),
                            lng: parseFloat(this.dataset.lng)
                        };

                        $.ajax({
                            url: (window.myApp && window.myApp.contextPath ? window.myApp.contextPath : '') + "/favorites/toggle", // 기존 토글 API 사용
                            method: "POST",
                            contentType: "application/json",
                            data: JSON.stringify(payload),
                            success: function(response) {
                                alert(response.message);
                                if (response.status === 'success' && response.action === 'removed') {
                                    // 페이지에서 해당 항목 즉시 제거
                                    const itemToRemove = document.getElementById('fav-item-' + statId);
                                    if (itemToRemove) {
                                        itemToRemove.remove();
                                    }
                                    // 전역 JavaScript Set에서도 ID 제거 (main.jsp와 상태 동기화)
                                    if (window.userFavoriteStationIds) {
                                        window.userFavoriteStationIds.delete(statId);
                                    }
                                    // 목록이 비었는지 확인하고 "없음" 메시지 표시
                                    if (document.querySelectorAll('.favorite-item-card').length === 0) {
                                        const noFavsMsg = document.querySelector('.no-favorites-info');
                                        if (noFavsMsg) noFavsMsg.style.display = 'block';
                                    }
                                }
                            },
                            error: function(jqXHR) {
                                let errorMsg = "즐겨찾기 삭제 중 오류가 발생했습니다.";
                                if (jqXHR.responseJSON && jqXHR.responseJSON.message) {
                                    errorMsg = jqXHR.responseJSON.message;
                                }
                                alert(errorMsg);
                            }
                        });
                    }
                });
            });

            // "지도에서 보기" 링크에 파라미터 추가 (main.jsp가 이 파라미터를 처리하도록 수정 필요)
            // 예를 들어, main.jsp 로드 시 URL 파라미터를 확인하여 해당 위치로 지도 이동 및 상세 정보창 자동 오픈
            // 위 HTML의 a 태그 href에 &openDetail=true 와 같은 파라미터를 추가해두었습니다.
        });
    </script>
</body>
<style>
body {
    font-family: Arial, sans-serif;
    background-color: #f4f7f6;
    margin: 0;
    padding: 0;
}

.favorites-container {
    max-width: 1200px;
    margin: 20px auto;
    padding: 20px;
    /* background-color: #f9f9f9; */ /* body 배경색과 유사하면 생략 가능 */
}

.favorites-container h1 {
    text-align: center;
    margin-bottom: 30px;
    color: #333;
    font-size: 2em;
}

.favorite-items-grid {
    list-style: none;
    padding: 0;
    display: grid;
    /* grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); */ /* 카드 너비 자동 조절 */
    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); /* 좀 더 유연한 반응형 */
    gap: 25px;
}

.favorite-item-card {
    background-color: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0,0,0,0.08);
    padding: 20px;
    display: flex;
    flex-direction: column;
    transition: box-shadow 0.3s ease;
}

.favorite-item-card:hover {
    box-shadow: 0 6px Px rgba(0,0,0,0.12);
}

.favorite-card-header .station-name {
    font-size: 1.25em;
    color: #007bff;
    margin-top: 0;
    margin-bottom: 12px;
    word-break: keep-all;
}

.favorite-card-body .address {
    font-size: 0.95em;
    color: #555;
    margin-bottom: 15px;
    line-height: 1.5;
}
.favorite-card-body .address .fa-map-marker-alt {
    margin-right: 6px;
    color: #777;
}

.favorite-card-actions {
    margin-top: auto;
    padding-top: 15px;
    border-top: 1px solid #f0f0f0;
    display: flex;
    gap: 10px;
}

.favorite-card-actions .action-btn {
    flex: 1; /* 버튼이 가능한 공간을 동일하게 차지 */
    padding: 10px 15px;
    text-decoration: none;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    text-align: center;
    font-size: 0.9em;
    transition: background-color 0.2s ease;
}

.favorite-card-actions .view-map-btn {
    background-color: #17a2b8; /* Info Blue */
}
.favorite-card-actions .view-map-btn:hover {
    background-color: #138496;
}

.favorite-card-actions .remove-fav-btn {
    background-color: #dc3545; /* Red */
}
.favorite-card-actions .remove-fav-btn:hover {
    background-color: #c82333;
}

.favorite-card-actions .action-btn .fas {
    margin-right: 5px;
}

.no-favorites-info {
    text-align: center;
    font-size: 1.1em;
    color: #6c757d; /* Bootstrap muted color */
    padding: 50px 20px;
    background-color: #fff;
    border: 1px dashed #ced4da;
    border-radius: 8px;
    margin-top: 20px;
}
.no-favorites-info .fas {
    color: #ffc107; /* Bootstrap warning color for star */
}
.no-favorites-info .fa-heart {
     color: #e74c3c;
}


.error-message {
    color: #dc3545; /* Bootstrap danger color */
    text-align: center;
    margin: 20px 0;
    padding: 10px;
    background-color: #f8d7da;
    border: 1px solid #f5c6cb;
    border-radius: 5px;
    font-weight: bold;
}
</style>
</html>