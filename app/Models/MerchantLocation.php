<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MerchantLocation extends Model
{
    protected $primaryKey = 'location_id';

    protected $fillable = ['merchant_id', 'address', 'city', 'province', 'latitude', 'longitude'];

    protected function casts(): array
    {
        return ['latitude' => 'decimal:7', 'longitude' => 'decimal:7'];
    }

    public function merchant(): BelongsTo
    {
        return $this->belongsTo(Merchant::class, 'merchant_id', 'merchant_id');
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class, 'location_id', 'location_id');
    }
}
