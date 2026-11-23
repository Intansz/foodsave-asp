<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::middleware('auth')->group(function () {
    // Setelah login, arahkan pengguna ke halaman sesuai role.
    Route::get('/dashboard', function () {
        return match (auth()->user()->role?->role_name) {
            'admin' => redirect('/admin'),
            'mitra' => redirect('/mitra'),
            default => redirect('/konsumen'),
        };
    })->name('dashboard');

    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

Route::middleware(['auth', 'role:konsumen'])->get('/konsumen', fn () => view('konsumen.dashboard'))->name('konsumen.dashboard');
Route::middleware(['auth', 'role:mitra'])->get('/mitra', fn () => view('mitra.dashboard'))->name('mitra.dashboard');
Route::middleware(['auth', 'role:admin'])->get('/admin', fn () => view('admin.dashboard'))->name('admin.dashboard');

require __DIR__.'/auth.php';
