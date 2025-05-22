package com.boot.favorite.controller;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.boot.favorite.dto.FavoriteRequestDTO;
import com.boot.favorite.service.FavoriteService;
// Assuming you have a User DTO or similar for session
// import com.boot.user.dto.UserDTO; 

@RestController
@RequestMapping("/favorites") // Base path for these actions
public class FavoriteController {

    @Autowired
    private FavoriteService favoriteService;

    @PostMapping("/toggle")
    public ResponseEntity<Map<String, Object>> toggleFavorite(@RequestBody FavoriteRequestDTO favoriteRequest, HttpSession session) {


        if (favoriteRequest.getStat_id() == null || favoriteRequest.getStat_id().trim().isEmpty()) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "충전소 ID(stat_id)는 필수입니다.");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
         if (favoriteRequest.getUser_no() <= 0) { // Basic validation for user_no
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "유효한 사용자 번호(user_no)가 필요합니다.");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }


        try {
            Map<String, Object> result = favoriteService.toggleFavorite(favoriteRequest);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            // Log the exception (e.g., using SLF4J logger)
            // logger.error("Error in toggleFavorite: ", e);
            System.err.println("Error in toggleFavorite: " + e.getMessage()); // Simple console log
            e.printStackTrace(); // For more details during dev

            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "서버 처리 중 오류가 발생했습니다. 다시 시도해주세요.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}