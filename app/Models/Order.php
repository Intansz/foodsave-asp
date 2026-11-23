<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Order extends Model
{
    protected $primaryKey = 'order_id';

    protected $fillable = ['user_id', 'merchant_id', 'order_code', 'order_date', 'order_status', 'total_amount'];

    protected function casts(): array
    {
        return ['order_date' => 'datetime', 'total_amount' => 'decimal:2'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'user_id');
    }

    public function merchant(): BelongsTo
    {
        return $this->belongsTo(Merchant::class, 'merchant_id', 'merchant_id');
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class, 'order_id', 'order_id');
    }

    public function review(): HasOne
    {
        return $this->hasOne(Review::class, 'order_id', 'order_id');
    }
}
