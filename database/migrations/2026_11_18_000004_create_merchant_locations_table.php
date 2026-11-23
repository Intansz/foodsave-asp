<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('merchant_locations', function (Blueprint $table) {
            $table->id('location_id');
            $table->foreignId('merchant_id')->constrained('merchants', 'merchant_id')->cascadeOnDelete()->cascadeOnUpdate();
            $table->string('address', 255);
            $table->string('city', 100);
            $table->string('province', 100);
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->timestamps();

            $table->index(['city', 'province'], 'idx_locations_city');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('merchant_locations');
    }
};
