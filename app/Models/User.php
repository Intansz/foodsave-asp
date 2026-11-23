<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    // Nama kolom mengikuti ERD (Bab IV): user_id dan password_hash.
    protected $primaryKey = 'user_id';

    protected $fillable = ['role_id', 'name', 'email', 'password', 'status'];

    protected $hidden = ['password_hash', 'remember_token'];

    protected function casts(): array
    {
        return ['email_verified_at' => 'datetime'];
    }

    // Atribut "password" (dipakai Breeze) dipetakan ke kolom password_hash.
    protected function password(): Attribute
    {
        return Attribute::make(
            get: fn () => $this->attributes['password_hash'] ?? null,
            set: fn ($value) => ['password_hash' => $value],
        );
    }

    public function getAuthPasswordName(): string
    {
        return 'password_hash';
    }

    public function getAuthPassword()
    {
        return $this->attributes['password_hash'] ?? null;
    }

    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class, 'role_id', 'role_id');
    }

    public function hasRole(string ...$roles): bool
    {
        return in_array($this->role?->role_name, $roles, true);
    }

    public function merchant(): HasOne
    {
        return $this->hasOne(Merchant::class, 'user_id', 'user_id');
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class, 'user_id', 'user_id');
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class, 'user_id', 'user_id');
    }
}
