package com.boot.favorite.service;

import com.boot.favorite.dao.FavoriteDAO;
import com.boot.favorite.dto.FavoriteDetailDTO;
import com.boot.favorite.dto.FavoriteToggleResponseDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // 트랜잭션 처리를 위해 추가

import java.util.List;
import java.util.Set;

@Service
public class FavoriteServiceImpl implements FavoriteService {
    private static final Logger logger = LoggerFactory.getLogger(FavoriteServiceImpl.class);
    private final FavoriteDAO favoriteDAO;

    @Autowired
    public FavoriteServiceImpl(FavoriteDAO favoriteDAO) {
        this.favoriteDAO = favoriteDAO;
    }

    @Override
    @Transactional
    public FavoriteToggleResponseDTO toggleFavorite(int user_no, String stat_id) {
        Integer favoriteRecordId = favoriteDAO.findFavoriteByStatId(user_no, stat_id);
        boolean successOperation;
        String actionTaken;
        boolean finalFavoriteState;
        String message = null; // 메시지 초기화

        if (favoriteRecordId != null) { // 이미 즐겨찾기에 있음 -> 삭제 시도
            successOperation = favoriteDAO.deleteFavorite(user_no, stat_id) > 0;
            actionTaken = "deleted";
            finalFavoriteState = false; 
            if (successOperation) {
                logger.info("즐겨찾기 삭제 성공: 사용자 번호 {}, 충전소 ID {}", user_no, stat_id);
            } else {
                message = "즐겨찾기 삭제에 실패했습니다."; // 실패 메시지 설정
                finalFavoriteState = true; // 삭제 실패했으므로 이전 상태 (즐겨찾기 상태) 유지
                logger.error("{} : 사용자 번호 {}, 충전소 ID {}", message, user_no, stat_id);
            }
        } else { // 즐겨찾기에 없음 -> 추가 시도
            successOperation = favoriteDAO.addFavorite(user_no, stat_id) > 0;
            actionTaken = "added";
            finalFavoriteState = true;
            if (successOperation) {
                logger.info("즐겨찾기 추가 성공: 사용자 번호 {}, 충전소 ID {}", user_no, stat_id);
            } else {
                message = "즐겨찾기 추가에 실패했습니다."; // 실패 메시지 설정
                finalFavoriteState = false; // 추가 실패했으므로 이전 상태 (즐겨찾기 안된 상태) 유지
                logger.error("{} : 사용자 번호 {}, 충전소 ID {}", message, user_no, stat_id);
            }
        }

        if (successOperation) {
            return new FavoriteToggleResponseDTO("success", null, actionTaken, finalFavoriteState);
        } else {
            String failureMessage = actionTaken.equals("added") ? "즐겨찾기 추가에 실패했습니다." : "즐겨찾기 삭제에 실패했습니다.";
            // 실패 시 isFavorite는 작업 전 상태를 반영
            boolean previousFavoriteState = (actionTaken.equals("added")) ? false : true;
            return new FavoriteToggleResponseDTO("error", failureMessage, actionTaken, previousFavoriteState);
        }
    }

    @Override
    public Set<String> getFavoriteStatIdsByUserNo(int user_no) {
        return favoriteDAO.findFavoriteStatIdsByUserNo(user_no);
    }
    
    @Override
    public List<FavoriteDetailDTO> getFavoriteDetailsByUserNo(int user_no) {
        return favoriteDAO.findFavoriteDetailsByUserNo(user_no);
    }
}