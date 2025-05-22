package com.boot.favorite.dao;

import com.boot.favorite.dto.FavoriteDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.Map;

@Mapper
public interface FavoriteDAO {
    FavoriteDTO findFavorite(Map<String, Object> params);
    int insertFavorite(FavoriteDTO favorite); // Parameter is now FavoriteDTO
    int deleteFavorite(Map<String, Object> params);
}