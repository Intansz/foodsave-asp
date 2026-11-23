<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;

class Merchant extends Model
{
    protected $primaryKey = 'merchant_id';

    protected $fillable = ['user_id', 'business_name', 'verification_status'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'user_id');
    }

    public function locations(): HasMany
    {
        return $this->hasMany(MerchantLocation::class, 'merchant_id', 'merchant_id');
    }

    // Produk dimiliki mitra melalui lokasi (merchants -> merchant_locations -> products).
    public function products(): HasManyThrough
    {
        return $this->hasManyThrough(
            Product::class, MerchantLocation::class,
            'merchant_id', 'location_id', 'merchant_id', 'location_id'
        );
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class, 'merchant_id', 'merchant_id');
    }
}
