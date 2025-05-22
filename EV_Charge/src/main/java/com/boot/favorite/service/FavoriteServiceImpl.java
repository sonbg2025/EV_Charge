package com.boot.favorite.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // Important for data consistency

import com.boot.favorite.dao.FavoriteDAO;
import com.boot.favorite.dto.FavoriteDTO;
import com.boot.favorite.dto.FavoriteRequestDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class FavoriteServiceImpl implements FavoriteService {

    @Autowired
    private FavoriteDAO favoriteDAO;

    @Override
    @Transactional // Ensures the whole operation is a single transaction
    public Map<String, Object> toggleFavorite(FavoriteRequestDTO favoriteRequest) {
        Map<String, Object> response = new HashMap<>();
        Map<String, Object> params = new HashMap<>();
        params.put("user_no", favoriteRequest.getUser_no());
        params.put("stat_id", favoriteRequest.getStat_id());

        FavoriteDTO existingFavorite = favoriteDAO.findFavorite(params);

        if (existingFavorite != null) {
            // Favorite exists, so remove it
            int deletedRows = favoriteDAO.deleteFavorite(params);
            if (deletedRows > 0) {
                response.put("status", "success");
                response.put("action", "removed");
                response.put("message", "즐겨찾기에서 삭제되었습니다.");
            } else {
                response.put("status", "error");
                response.put("message", "즐겨찾기 삭제에 실패했습니다.");
            }
        } else {
            // Favorite does not exist, so add it
            FavoriteDTO newFavorite = new FavoriteDTO();
            newFavorite.setUser_no(favoriteRequest.getUser_no());
            newFavorite.setStat_id(favoriteRequest.getStat_id());
            newFavorite.setAddr(favoriteRequest.getAddr());
            newFavorite.setAddr_detail(favoriteRequest.getAddr_detail());
            newFavorite.setLocation(favoriteRequest.getLocation());
            newFavorite.setLat(favoriteRequest.getLat());
            newFavorite.setLng(favoriteRequest.getLng());

            int insertedRows = favoriteDAO.insertFavorite(newFavorite);
            if (insertedRows > 0) {
                response.put("status", "success");
                response.put("action", "added");
                response.put("message", "즐겨찾기에 추가되었습니다.");
            } else {
                response.put("status", "error");
                response.put("message", "즐겨찾기 추가에 실패했습니다.");
            }
        }
        return response;
    }
    
    @Override
    public List<FavoriteDTO> getFavoriteDetailsList(int user_no) {
        log.info("Fetching all favorite details for user_no: {}", user_no);
        List<FavoriteDTO> favorites = favoriteDAO.findAllFavoritesByUserNo(user_no);
        return favorites != null ? favorites : new ArrayList<>(); // null 대신 빈 리스트 반환
    }
}