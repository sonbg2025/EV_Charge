package com.boot.favorite.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteToggleResponseDTO {
    private String status;
    private String message;
    private String action;
    private boolean isFavorite;
}