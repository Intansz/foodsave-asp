<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Product extends Model
{
    protected $primaryKey = 'product_id';

    protected $fillable = [
        'location_id', 'category_id', 'product_name', 'description', 'photo_url',
        'normal_price', 'discount_price', 'stock', 'pickup_deadline', 'status',
    ];

    protected function casts(): array
    {
        return [
            'normal_price' => 'decimal:2',
            'discount_price' => 'decimal:2',
            'stock' => 'integer',
            'pickup_deadline' => 'datetime',
        ];
    }

    // Produk yang boleh tampil di katalog: aktif, stok ada, belum lewat batas ambil.
    public function scopeTersedia(Builder $query): Builder
    {
        return $query->where('status', 'aktif')
            ->where('stock', '>', 0)
            ->where('pickup_deadline', '>', now());
    }

    public function location(): BelongsTo
    {
        return $this->belongsTo(MerchantLocation::class, 'location_id', 'location_id');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'category_id', 'category_id');
    }

    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItem::class, 'product_id', 'product_id');
    }
}
