package com.boot.favorite.dto;

import java.sql.Timestamp;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteDTO {
    private int favorite_id;
    private int user_no;
    private String stat_id;
    private String addr;
    private String addr_detail;
    private String location;
    private Double lat;
    private Double lng;
    private Timestamp created_at;
}