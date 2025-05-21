package com.boot.favorite.service;

import com.boot.favorite.dto.FavoriteDetailDTO;
import com.boot.favorite.dto.FavoriteToggleResponseDTO;
import java.util.List;
import java.util.Set;

public interface FavoriteService {

    /**
     * 즐겨찾기 상태를 토글합니다 (추가 또는 삭제).
     * @param user_no 사용자 번호
     * @param stat_id 충전소 ID (VARCHAR)
     * @return 토글 작업 결과 및 최종 즐겨찾기 상태를 담은 DTO
     */
    FavoriteToggleResponseDTO toggleFavorite(int user_no, String stat_id);

    /**
     * 특정 사용자의 모든 즐겨찾기된 충전소의 stat_id 목록을 가져옵니다.
     * @param user_no 사용자 번호
     * @return 즐겨찾기된 stat_id 문자열의 Set
     */
    Set<String> getFavoriteStatIdsByUserNo(int user_no);
    
    /**
     * 특정 사용자의 즐겨찾기 목록에 대한 상세 정보를 가져옵니다.
     * (ev_charger_data 테이블과 조인된 결과)
     * @param user_no 사용자 번호
     * @return 각 즐겨찾기 충전소의 상세 정보를 담은 FavoriteDetailDTO 리스트
     */
    List<FavoriteDetailDTO> getFavoriteDetailsByUserNo(int user_no);
}