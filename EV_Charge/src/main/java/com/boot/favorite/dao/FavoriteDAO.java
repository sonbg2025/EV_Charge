package com.boot.favorite.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.boot.favorite.dto.FavoriteDTO;

@Mapper
public interface FavoriteDAO {
    FavoriteDTO findFavorite(Map<String, Object> params);
    int insertFavorite(FavoriteDTO favorite); // Parameter is now FavoriteDTO
    int deleteFavorite(Map<String, Object> params);
    List<FavoriteDTO> findAllFavoritesByUserNo(@Param("user_no") int user_no);

}