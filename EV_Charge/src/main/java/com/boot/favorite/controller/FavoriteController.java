package com.boot.favorite.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.boot.dto.MemberDTO;
import com.boot.favorite.dto.FavoriteDTO;
import com.boot.favorite.dto.FavoriteRequestDTO;
import com.boot.favorite.service.FavoriteService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
public class FavoriteController {

    @Autowired
    private FavoriteService favoriteService;

    @PostMapping("/favorites/toggle")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleFavorite(@RequestBody FavoriteRequestDTO favoriteRequest, HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("user");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
        }
        if (loginUser.getUser_no() != favoriteRequest.getUser_no()) {
            return ResponseEntity.status(403).body(Map.of("status", "error", "message", "권한이 없습니다."));
        }

        Map<String, Object> result = favoriteService.toggleFavorite(favoriteRequest);
        return ResponseEntity.ok(result);
    }

    // 기존 /favorites/list GET 매핑 (JSON 응답, 사이드바용) - AJAX 호출용
    @GetMapping("/favorites/list")
    @ResponseBody // JSON 응답
    public ResponseEntity<?> getUserFavoritesForSidebar(HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("user");
        if (loginUser == null) {
            return ResponseEntity.status(401).body(Map.of("status", "error", "message", "로그인이 필요합니다."));
        }
        try {
            List<FavoriteDTO> favoriteList = favoriteService.getFavoriteDetailsList(loginUser.getUser_no());
            return ResponseEntity.ok(favoriteList);
        } catch (Exception e) {
            log.error("Error fetching favorites list for sidebar for user {}: {}", loginUser.getUser_no(), e.getMessage());
            return ResponseEntity.status(500).body(Map.of("status", "error", "message", "목록 조회 중 오류 발생"));
        }
    }


    // --- 새로운 즐겨찾기 페이지를 위한 GET 매핑 ---
    @RequestMapping("/favorites") // header.jsp의 링크 경로와 일치
    public String showFavoritesPage(HttpSession session, Model model) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("user");

        if (loginUser == null) {
            return "redirect:/login";
        }

        try {
            List<FavoriteDTO> favoritesList = favoriteService.getFavoriteDetailsList(loginUser.getUser_no());
            model.addAttribute("favoritesList", favoritesList);
            model.addAttribute("pageTitle", "나의 즐겨찾기"); // 페이지 제목 설정
        } catch (Exception e) {
            log.error("Error fetching favorites page for user {}: {}", loginUser.getUser_no(), e.getMessage(), e);
            model.addAttribute("errorMessage", "즐겨찾기 목록을 불러오는 중 오류가 발생했습니다.");
            model.addAttribute("favoritesList", new ArrayList<FavoriteDTO>()); // 오류 시 빈 리스트 전달
        }
        
        return "favorites_page";
    }
}