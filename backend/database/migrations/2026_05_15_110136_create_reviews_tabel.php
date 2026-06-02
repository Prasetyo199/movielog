<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reviews_tabel', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); 
            $table->string('title');                  // Judul film/series
            $table->enum('type', ['film', 'series']);  // Jenis: film atau series
            $table->string('genre');                  // Genre film
            $table->integer('release_year');           // Tahun rilis
            $table->integer('rating');                 // Rating pribadi (misal skala 1-5 atau 1-10)
            $table->text('review_text');               // Ulasan/review panjang
            $table->timestamps();
            
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews_tabel');
    }
};
