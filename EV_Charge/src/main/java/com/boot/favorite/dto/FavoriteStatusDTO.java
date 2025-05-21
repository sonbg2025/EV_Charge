package com.boot.favorite.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteStatusDTO {
    private String status;
    private String message;
    private Set<String> favoriteStationIds;
}