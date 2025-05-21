package com.boot.favorite.controller;

import java.util.HashMap;	
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.boot.favorite.dto.FavoriteDetailDTO;
import com.boot.favorite.dto.FavoriteRequestDTO;
import com.boot.favorite.dto.FavoriteStatusDTO;
import com.boot.favorite.dto.FavoriteToggleResponseDTO;
import com.boot.favorite.service.FavoriteService;

@RestController
@RequestMapping("/favorite") // API 공통 경로
public class FavoriteController {

    private static final Logger logger = LoggerFactory.getLogger(FavoriteController.class);
    private final FavoriteService favoriteService;

    @Autowired
    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

 // FavoriteController.java - /toggle 메서드
    @PostMapping("/toggle")
    public ResponseEntity<FavoriteToggleResponseDTO> toggleFavorite(@RequestBody FavoriteRequestDTO request) {
        // ... (입력값 유효성 검사) ...
        
        logger.info("즐겨찾기 토글 요청 수신: 사용자 번호 {}, 충전소 ID {}", request.getUser_no(), request.getStat_id());
        FavoriteToggleResponseDTO responseDto = favoriteService.toggleFavorite(request.getUser_no(), request.getStat_id()); // 서비스 호출
        
        if ("success".equals(responseDto.getStatus())) { // 서비스 DTO의 status 필드 확인
            return ResponseEntity.ok(responseDto); // HTTP 200 OK 와 함께 DTO 반환
        } else {
            // 서비스에서 이미 오류 메시지와 상태를 DTO에 설정했을 것임
            // HTTP 상태 코드는 여기서 결정 (예: 400 Bad Request 또는 500 Internal Server Error)
            // 현재는 서비스 로직에서 successOperation이 false면 INTERNAL_SERVER_ERROR로 응답하도록 되어 있음
            // 하지만 서비스 DTO의 status가 "error" 라면, 그 메시지를 담아 클라이언트에게 보내는 것이 좋음
            // 예를 들어, 항상 ResponseEntity.ok()로 보내되, DTO 내부의 status로 성공/실패를 구분하게 할 수도 있고,
            // DTO의 status가 "error"면 HTTP 상태 코드를 4xx나 5xx로 보낼 수도 있음.
            // 이전 코드에서는 INTERNAL_SERVER_ERROR로 보냈었음:
            // return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(responseDto);

            // 더 나은 방법: 서비스 DTO의 status가 "error"일 경우, 적절한 HTTP 상태코드와 함께 DTO 반환
            // 여기서는 일단 서비스 DTO의 상태를 존중하되, 클라이언트가 HTTP 200을 받도록 수정 (프론트 JS 조건 단순화 위함)
            // 만약 서비스 로직 실패 시에도 HTTP 200을 보내고 DTO 내부의 status로만 구분한다면 아래와 같이 할 수 있음:
            // return ResponseEntity.ok(responseDto);

            // 하지만 일반적으로 작업 실패 시에는 200 OK가 아닌 다른 상태 코드를 보내는 것이 RESTful 원칙에 더 부합.
            // 여기서는 서비스가 "error" 상태를 반환했다면, 그 메시지를 포함하여 클라이언트 에러(400) 또는 서버 에러(500)로 응답.
            // 서비스의 toggleFavorite 구현에서 DB 실패 시 "error" 메시지를 설정했으므로, 여기선 400을 보내는 것이 적절할 수 있음.
            // (DB 작업 실패는 보통 500이지만, 여기서는 클라이언트 요청에 따른 '처리 실패'로 간주)
            return ResponseEntity.badRequest().body(responseDto); 
        }
    }

    @GetMapping("/status")
    public ResponseEntity<FavoriteStatusDTO> getFavoriteStatusForUser(@RequestParam("user_no") int user_no) {
         if (user_no <= 0) {
            logger.warn("잘못된 즐겨찾기 상태 요청: user_no={}", user_no);
            return ResponseEntity.badRequest().body(new FavoriteStatusDTO("error", "유효한 사용자 번호는 필수입니다.", null));
        }
        logger.info("사용자 즐겨찾기 상태 목록 요청: 사용자 번호 {}", user_no);
        try {
            Set<String> favoriteStatIds = favoriteService.getFavoriteStatIdsByUserNo(user_no);
            return ResponseEntity.ok(new FavoriteStatusDTO("success", null, favoriteStatIds));
        } catch (Exception e) {
            logger.error("사용자 즐겨찾기 상태 목록 조회 중 서버 오류 발생: 사용자 번호 {}", user_no, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new FavoriteStatusDTO("error", "서버 내부 오류로 즐겨찾기 상태를 조회할 수 없습니다.", null));
        }
    }
    
    @GetMapping("/list/details")
    public ResponseEntity<?> getFavoriteDetails(@RequestParam("user_no") int user_no) {
        if (user_no <= 0) {
             logger.warn("잘못된 즐겨찾기 상세 목록 요청: user_no={}", user_no);
            return ResponseEntity.badRequest().body("유효한 사용자 번호는 필수입니다.");
        }
        logger.info("사용자 즐겨찾기 상세 목록 요청: 사용자 번호 {}", user_no);
        try {
            List<FavoriteDetailDTO> favoriteDetails = favoriteService.getFavoriteDetailsByUserNo(user_no);
            return ResponseEntity.ok(favoriteDetails);
        } catch (Exception e) {
            logger.error("사용자 즐겨찾기 상세 목록 조회 중 서버 오류 발생: 사용자 번호 {}", user_no, e);
            // 좀 더 구체적인 오류 DTO를 반환하거나, 간단한 메시지 반환
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "서버 내부 오류로 즐겨찾기 상세 목록을 가져올 수 없습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
    
}