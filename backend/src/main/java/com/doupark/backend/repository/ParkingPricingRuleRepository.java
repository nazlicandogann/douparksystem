package com.doupark.backend.repository;

import com.doupark.backend.entity.ParkingPricingRule;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ParkingPricingRuleRepository extends JpaRepository<ParkingPricingRule, Long> {
    Optional<ParkingPricingRule> findByParking_Id(Long parkingId);
}
