package com.boot.favorite.dao;

import com.boot.favorite.dto.FavoriteDetailDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Set;

@Mapper
public interface FavoriteDAO {

    /**
     * 사용자의 즐겨찾기 목록에서 특정 충전소가 있는지 확인 (stat_id 기준)
     * @param user_no 사용자 번호
     * @param stat_id 충전소 ID (VARCHAR)
     * @return 즐겨찾기 레코드의 favorite_id (존재하면) 또는 null (존재하지 않으면)
     */
    Integer findFavoriteByStatId(@Param("user_no") int user_no, @Param("stat_id") String stat_id);

    /**
     * 즐겨찾기 추가
     * @param user_no 사용자 번호
     * @param stat_id 충전소 ID (VARCHAR)
     * @return 영향을 받은 행 수 (일반적으로 1)
     */
    int addFavorite(@Param("user_no") int user_no, @Param("stat_id") String stat_id);

    /**
     * 즐겨찾기 삭제
     * @param user_no 사용자 번호
     * @param stat_id 충전소 ID (VARCHAR)
     * @return 영향을 받은 행 수 (일반적으로 1)
     */
    int deleteFavorite(@Param("user_no") int user_no, @Param("stat_id") String stat_id);

    /**
     * 특정 사용자의 모든 즐겨찾기 stat_id 목록 조회
     * @param user_no 사용자 번호
     * @return 즐겨찾기된 stat_id의 Set
     */
    Set<String> findFavoriteStatIdsByUserNo(@Param("user_no") int user_no);
    
    /**
     * 특정 사용자의 즐겨찾기 목록 상세 정보 조회 (ev_charger_data와 조인)
     * @param user_no 사용자 번호
     * @return FavoriteDetailDTO 리스트 (각 즐겨찾기 충전소의 상세 정보 포함)
     */
    List<FavoriteDetailDTO> findFavoriteDetailsByUserNo(@Param("user_no") int user_no);
}