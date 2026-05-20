<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;
    protected $table = 'reviews_tabel';
    // Mendaftarkan kolom yang boleh diisi (Mass Assignment)
    protected $fillable = [
        'user_id',
        'title',
        'type',
        'genre',
        'release_year',
        'rating',
        'review_text',
    ];

    // Hubungan Relasi: Setiap review pasti dimiliki oleh satu User
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    // Hubungan Relasi: Satu user bisa menulis banyak review
    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}