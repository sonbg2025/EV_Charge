package com.boot.favorite.service;

import com.boot.favorite.dto.FavoriteRequestDTO;
import java.util.Map;

public interface FavoriteService {
    Map<String, Object> toggleFavorite(FavoriteRequestDTO favoriteRequest);
}