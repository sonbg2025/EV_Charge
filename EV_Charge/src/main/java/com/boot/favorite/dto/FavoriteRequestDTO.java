package com.boot.favorite.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteRequestDTO {
    private int user_no;
    private String stat_id;
}