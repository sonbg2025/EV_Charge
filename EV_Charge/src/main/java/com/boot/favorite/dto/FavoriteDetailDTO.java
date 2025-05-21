package com.boot.favorite.dto;

import lombok.Data;	
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteDetailDTO {
    private String stat_id;
    private String stn_place;
    private String stn_addr;
    private Double evse_location_latitude;
    private Double evse_location_longitude;
}