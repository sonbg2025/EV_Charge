<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
   <!DOCTYPE html>
   <html lang="ko">

   <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Document</title>

      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
      <script src="${pageContext.request.contextPath}/js/jquery.js"></script>
<!--	  ---------------------------------------------추가시킴------------------->
<c:if test="${not empty sessionScope.user && not empty sessionScope.user.user_no}">
    <script>
        window.APP_USER_NO = parseInt(${sessionScope.user.user_no});
        // 디버깅을 위해 콘솔에 로그를 추가합니다.
        console.log('[Main JSP] 로그인된 사용자 번호 (window.APP_USER_NO):', window.APP_USER_NO);
    </script>
</c:if>
<c:if test="${empty sessionScope.user || empty sessionScope.user.user_no}">
    <script>
        window.APP_USER_NO = null;
        // 디버깅을 위해 콘솔에 로그를 추가합니다.
        console.log('[Main JSP] 사용자가 로그인하지 않았거나 사용자 번호가 없습니다. window.APP_USER_NO는 null입니다.');
    </script>
</c:if>
<!------------------------------------------------------------------------------------------>

      <style>
         html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            /* overflow: hidden; */
            }
            #reset{
               position: fixed;
               bottom: 50px;
               left: 1000px;
               z-index: 1000;
               padding: 10px 20px;
               border-radius: 30px;
               font-weight: bolder;
               background-color: #0475f4;
               color: white;
            }
            #reset:hover{
               background-color: #0062d3;
               cursor: pointer;
            }
            #reset i{
               transition: transform 0.7s ease;
            }
            #reset:hover i{
               transform: rotate(180deg);
            }
      </style>
   </head>

   <body>
      <script type="text/javascript"
         src="//dapi.kakao.com/v2/maps/sdk.js?appkey=109dd4a6fbdf108d896544146388b47e"></script>
	
	  <!-- 헤더 -->
      <jsp:include page="/WEB-INF/views/header.jsp" />
	  <!-- 사이드바 -->
      <jsp:include page="/WEB-INF/views/favorites_sidebar.jsp"/>
      <jsp:include page="/WEB-INF/views/station_detail.jsp"/>
      <!-- 지도 표시 -->
      <div id="map" style="width:100%;height:93%;"></div>

      <div id="reset"><i class="fas fa-sync-alt"></i> &nbsp;현 지도에서 검색</i>
</div>

      <!-- 추후에 사용자 세션 받아서 blind 및 display 처리 요망. -->
      <!-- 사용자 세션 받으면 center_lat과 center_lng는 사용자 가입시 설정되는 area 값으로 지정 -->

      <script type="text/javascript">
         var mapContainer = document.getElementById('map'); // 지도를 표시할 div  
         var markers = [];
         var center_lat; // 서버에서 전달된 위도
         var center_lng; // 서버에서 전달된 경도
         if (center_lat == null && center_lng == null) {
            center_lat = 37.5400456;
            center_lng = 126.9921017;
         };	

         var mapOption = {
            center: new kakao.maps.LatLng(center_lat, center_lng), // 지도의 중심좌표
            level: 3 // 지도의 확대 레벨
         };

         var map = new kakao.maps.Map(mapContainer, mapOption); // 지도를 생성합니다

         kakao.maps.event.addListener(map, 'center_changed', function () {
            var latlng = map.getCenter();
            center_lat = latlng.getLat();
            center_lng = latlng.getLng();
            console.log('현재 중심 좌표:', center_lat, center_lng);
         });

         // 읍/면/동 옵션 업데이트 함수
         function updatearea_emd_nm() {
            const area_ctpy_nm = document.getElementById("area_ctpy_nm").value;
           const area_sgg_nm = document.getElementById("area_sgg_nm").value;
            const area_emd_nmSelect = document.getElementById("area_emd_nm");

            // 읍/면/동 초기화
           area_emd_nmSelect.innerHTML = '<option value="">선택하세요</option>';

          if (area_ctpy_nm && area_sgg_nm && regions[area_ctpy_nm] && regions[area_ctpy_nm][area_sgg_nm]) {
              const area_emd_nms = regions[area_ctpy_nm][area_sgg_nm];
               area_emd_nms.forEach(area_emd_nm => {
                  const option = document.createElement("option");
               option.value = area_emd_nm;
                 option.text = area_emd_nm;
                  area_emd_nmSelect.appendChild(option);
               });
           }
         }

         window.addMarker = function(stat_id, address, lat, lng, name, rapid, slow, car) {
            const position = new kakao.maps.LatLng(lat, lng);
            const marker = new kakao.maps.Marker({
               position: position,
               map: map,
               name: name
            });
            console.log("마커를 찍었습니다. => "+lat+", "+lng);
            markers.push(marker); // 마커 배열에 추가

            var infowindow = new kakao.maps.InfoWindow({
               content: '<div style="padding:5px;font-size:12px;">'+name+'</div>'
            });

            let isOpen = false;

            // 마커 클릭
            kakao.maps.event.addListener(marker, 'click', function() {
               console.log("마커를 클릭했습니다. 위치: " + lat + ", " + lng + ", 이름: " + name);
      
               map.setCenter(new kakao.maps.LatLng(lat, lng-0.003));
               map.setLevel(3);

               infowindow.open(map, marker);

               $("#close-detail-sidebar,#close-sidebar").on("click", function () {
                  infowindow.close();
               });
               
               
               // 마커 클릭했을때 사이드바 생성 및 데이터 전달
               $(".station-sidebar").addClass("active");
               $(".station-sidebarA").addClass("active");
               var markerData = {
                  name: name
				  ,stat_id: stat_id
                  ,address: address
                  ,lat: lat
                  ,lng: lng
                  ,rapid: rapid
                  ,slow: slow
                  ,car: car
               }
               
               console.log(markerData);
               // 충전소 상세 정보 업데이트
               updateStationDetailTwo(markerData);
            });

			   // 지도 클릭 액션
            kakao.maps.event.addListener(map, 'click', function() {
               infowindow.close();
               isOpen = false;
               // $(".station-sidebar").removeClass("active");
               $(".station-sidebarA").removeClass("active");
               // 마커지우기
               // for (var i = 0; i < markers.length; i++) {
               //    markers[i].setMap(null);
               // }
               // markers = [];
            });
            return marker;
         };

         window.map = map;
         window.markers = markers;

         $(document).ready(function () {
            // 사이드바 관련 닫기
            $("#close-sidebar").on("click", function () {
               $(".station-sidebar").removeClass("active");
               $(".station-sidebarA").removeClass("active");
               // infowindow.close();
            });

            // 사이드바 관련 열기
            $("#bars").on("click", function () {
               $(".station-sidebar").toggleClass("active");
               if( $(".station-sidebarA").hasClass("active")){
                  $(".station-sidebarA").removeClass("active");                  
               }
            });

            // 검색 클릭
            $("#search_btn").on("click", function () {
               const area_ctpy_nm_val = $("#area_ctpy_nm").val();
               const area_sgg_nm_val = $("#area_sgg_nm").val();
               const area_ctpy_nm = $("#area_ctpy_nm option:selected").text();
               const area_sgg_nm = $("#area_sgg_nm option:selected").text();
               const area_emd_nm = $("#area_emd_nm").val();

               if (!area_ctpy_nm || !area_sgg_nm || !area_emd_nm) {
                  alert("모든 주소 항목을 선택해주세요.");
                  return;
               }

               // findStationsNear 호출
               $.ajax({
                  type: "post",
                  url: "/findStationsNear",
                  data: {
                     area_ctpy_nm: area_ctpy_nm_val,
                     area_sgg_nm: area_sgg_nm_val
                  },
                  success: function (addr_place_list) {
                     // alert("1단계 성공: " + JSON.stringify(addr_list));
                     console.log("1단계 성공");
                     console.log(addr_place_list);
                     
                     //----------------------------------
                     // 폼 데이터를 서버로 전송
                     fetch('/updateMapCoordinates', {
                        method: 'POST',
                        headers: {
                           'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                           area_ctpy_nm: area_ctpy_nm,
                           area_sgg_nm: area_sgg_nm,
                           area_emd_nm: area_emd_nm
                        })
                     })
                        .then(response => response.json())
                        .then(data => {
                           // 서버에서 받은 위도와 경도로 지도 중심 좌표 갱신
                           if (data.latitude && data.longitude) {
                              center_lat = data.latitude;
                              center_lng = data.longitude;
                              var newCenter = new kakao.maps.LatLng(center_lat, center_lng);
                              map.setCenter(newCenter);
                              console.log("@# 새로운 중심 좌표:", center_lat, center_lng);

                              fetch("/search_data", {
                                 method: "POST"
                                 ,headers: {
                                    "Content-Type": "application/json"
                                 }
                                 ,body: JSON.stringify({
                                    lat: center_lat,
                                    lng: center_lng
                                 }) 
                              })
                              .then(response => response.json())
                              .then(data => {
                                 console.log("서버 응답 데이터 => ", data);
                                 for (var i = 0; i < markers.length; i++) {
                                    markers[i].setMap(null);
                                 }
                                 markers = [];
                                 markerInfoMap = {};  // 초기화

                                 // 같은 위치끼리 그룹핑
                                 data.forEach(charger => {
                                       const key = charger.lat+","+charger.lng;
                                       if (!markerInfoMap[key]) {
                                          markerInfoMap[key] = [];
                                       }
                                       markerInfoMap[key].push(charger);
                                       // console.log(markerInfoMap[key]);
                                 });

                                 // 마커 찍기 (중복 없이)
                                 Object.entries(markerInfoMap).forEach(([key, chargers]) => {
                                       const [lat, lng] = key.split(',').map(Number);
                                       window.addMarker_two(lat, lng, chargers);
                                       // console.log("chargers => ", chargers);
                                 });
                              })
                              .catch(error => {
                                 console.error("오류 발생 => ", error);
                              });

                           } else {
                              alert("해당 정보는 없는 정보입니다.");
                           }
                        })
                        .catch(error => {
                           console.error("Error:", error);
                           alert("위도 경도 변환 중 오류가 발생했습니다.");
                        });
                     
                  },
                  error: function () {
                     alert("1단계 오류");
                  }
               });
            });
         });


         window.addMarker_two = function(lat, lng, chargerList) {
            console.log("마커찍기");
            // console.log("chargerList => ", chargerList);
            const key = lat+","+lng;
            const position = new kakao.maps.LatLng(lat, lng);

            const marker = new kakao.maps.Marker({
               position: position,
               map: map
            });

            markers.push(marker);

			// 마커 클릭 이벤트
			          kakao.maps.event.addListener(marker, 'click', function () {
			             console.log("addMarker_two 클릭됨 =>", lat, lng, "충전기 개수:", chargerList.length);

			             if (!chargerList || chargerList.length === 0) {
			                 console.error("addMarker_two 클릭: chargerList가 비어있거나 유효하지 않습니다.");
			                 alert("선택한 충전소의 상세 정보를 가져올 수 없습니다.");
			                 return;
			             }

			             // chargerList의 첫 번째 요소를 기준으로 상세 정보를 표시한다고 가정
			             const firstCharger = chargerList[0];

			             if (!firstCharger || !firstCharger.stat_id || firstCharger.stat_id.trim() === "") {
			                 console.error("addMarker_two 클릭: 첫 번째 충전기 정보에 유효한 stat_id가 없습니다.", firstCharger);
			                 alert("선택한 충전소의 ID 정보가 없어 상세 정보를 표시할 수 없습니다.");
			                 return;
			             }
			              console.log("addMarker_two 클릭: 전달할 첫 번째 충전소 정보 (stat_id 포함):", firstCharger);


			             map.setCenter(new kakao.maps.LatLng(lat, lng - 0.003));
			             map.setLevel(3);

			             $(".station-sidebar").addClass("active"); // 목록 사이드바도 함께 열리는지 확인 필요
			             $(".station-sidebarA").addClass("active");

			             // updateStationDetailTwo 함수는 chargerList를 포함하는 객체를 기대함
			             const markerData = {
			                   // lat, lng은 chargerList[0]에 이미 있으므로 중복이지만, 명시적으로 전달해도 무방
			                   lat: firstCharger.lat, // 또는 lat 파라미터 사용
			                   lng: firstCharger.lng, // 또는 lng 파라미터 사용
			                   chargerList: chargerList // 전체 chargerList 전달
			             };
			             
			             // updateStationDetailTwo 호출 전에 stat_id가 있는지 다시 확인
			             console.log("addMarker_two: updateStationDetailTwo 호출 직전 markerData.chargerList[0].stat_id:", markerData.chargerList[0].stat_id);

			             if (window.updateStationDetailTwo) {
			                 updateStationDetailTwo(markerData);
			             } else {
			                 console.error("updateStationDetailTwo 함수를 찾을 수 없습니다.");
			             }
			          });

            return marker;
         };

         $(document).on("click", "#reset", function (e) {
            console.log("현 지도에서 검색 클릭");
            console.log(center_lat + " / " + center_lng);

            fetch("/search_data", {
                method: "POST"
               ,headers: {
                  "Content-Type": "application/json"
               }
               ,body: JSON.stringify({
                  lat: center_lat,
                  lng: center_lng
               }) 
            })
            .then(response => response.json())
            .then(data => {
               console.log("서버 응답 데이터 => ", data);
               for (var i = 0; i < markers.length; i++) {
                  markers[i].setMap(null);
               }
               // data.forEach(charger => {
               //    window.addMarker(
               //              charger.lat,
               //              charger.lng,
               //              charger.stat_name
               //          );
               // });
               markers = [];
               markerInfoMap = {};  // 초기화

               // 같은 위치끼리 그룹핑
               data.forEach(charger => {
                     const key = charger.lat+","+charger.lng;
                     if (!markerInfoMap[key]) {
                        markerInfoMap[key] = [];
                     }
                     markerInfoMap[key].push(charger);
                     // console.log(markerInfoMap[key]);
               });

               // 마커 찍기 (중복 없이)
               Object.entries(markerInfoMap).forEach(([key, chargers]) => {
                     const [lat, lng] = key.split(',').map(Number);
                     window.addMarker_two(lat, lng, chargers);
                     // console.log("chargers => ", chargers);
               });
            })
            .catch(error => {
               console.error("오류 발생 => ", error);
            });
         });

		 window.userFavoriteStationIds = new Set(); // 먼저 빈 Set으로 선언

		     async function initializeGlobalFavoriteStatus() {
		         const currentLoggedInUserNo = window.APP_USER_NO; // ⭐ 2. 설정된 전역 user_no 사용

		         if (!currentLoggedInUserNo || currentLoggedInUserNo <= 0) {
		             console.log('[전역] 비로그인 상태. 즐겨찾기 초기화 안함.');
		             return;
		         }

		         try {
		             const response = await fetch(`/favorite/status?user_no=${currentLoggedInUserNo}`);
		             const data = await response.json();
		             if (data.status === 'success' && Array.isArray(data.favoriteStationIds)) {
		                 window.userFavoriteStationIds = new Set(data.favoriteStationIds); // ⭐ 3. 전역 Set 채우기
		                 console.log('[전역] 즐겨찾기 목록 로드 완료:', Array.from(window.userFavoriteStationIds));
		             } else {
		                 console.warn('[전역] 즐겨찾기 목록 로드 실패:', data.message || 'API 응답 오류');
		             }
		         } catch (error) {
		             console.error('[전역] 즐겨찾기 목록 로드 중 예외:', error);
		         }
		     }

		     document.addEventListener('DOMContentLoaded', function() {
		         // ⭐ 4. DOM 로드 후 (user_no가 확실히 설정된 후) 즐겨찾기 목록 가져오기
		         if (window.APP_USER_NO) { // 로그인 상태일 때만 호출
		             initializeGlobalFavoriteStatus();
		         }
		     });
      </script>
   </body>

   </html>