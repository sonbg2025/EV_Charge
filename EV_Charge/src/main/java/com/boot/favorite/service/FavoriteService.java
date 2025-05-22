package com.boot.favorite.service;

import java.util.List;
import java.util.Map;

import com.boot.favorite.dto.FavoriteDTO;
import com.boot.favorite.dto.FavoriteRequestDTO;

public interface FavoriteService {
    Map<String, Object> toggleFavorite(FavoriteRequestDTO favoriteRequest);
    List<FavoriteDTO> getFavoriteDetailsList(int user_no);

}