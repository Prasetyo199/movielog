<?php

namespace App\Http\Controllers;

use App\Models\Review;
use App\Models\Movie;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    // 1. READ (Melihat semua daftar ulasan film)
    public function index()
    {
        // Mengambil semua data review beserta data user yang membuatnya
        $reviews = Review::with('user')->latest()->get();
        $movies = Movie::get()->keyBy(function ($movie) {
            return strtolower($movie->title.'|'.$movie->type);
        });

        $reviews->transform(function ($review) use ($movies) {
            $movie = $movies->get(strtolower($review->title.'|'.$review->type));
            $review->poster_url = $movie?->poster_url;
            return $review;
        });

        return response()->json([
            'success' => true,
            'message' => 'Daftar review berhasil diambil',
            'data'    => $reviews
        ], 200);
    }

    // 2. CREATE (Menyimpan ulasan film baru ke database)
    public function store(Request $request)
    {
        // Validasi inputan terlebih dahulu demi keamanan database
        $data = $request->validate([
            'title'        => 'required|string|max:255',
            'type'         => 'required|in:film,series',
            'genre'        => 'required|string',
            'release_year' => 'required|integer',
            'rating'       => 'required|integer|between:1,5',
            'review_text'  => 'required|string',
        ]);
        $data['user_id'] = $request->user()->id;

        // Simpan data ke database
        $review = Review::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Review berhasil ditambahkan',
            'data'    => $review
        ], 201);
    }

    // 3. SHOW (Melihat detail dari satu review spesifik)
    public function show($id)
    {
        $review = Review::with('user')->find($id);

        if (!$review) {
            return response()->json([
                'success' => false,
                'message' => 'Review tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail review berhasil ditemukan',
            'data'    => $review
        ], 200);
    }

    // 4. UPDATE (Mengubah isi ulasan yang sudah ada)
    public function update(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json([
                'success' => false,
                'message' => 'Review tidak ditemukan'
            ], 404);
        }

        if (! $this->canManageReview($request, $review)) {
            return response()->json([
                'success' => false,
                'message' => 'Kamu tidak boleh mengubah review ini'
            ], 403);
        }

        // Validasi data baru yang dikirim
        $data = $request->validate([
            'rating'       => 'sometimes|required|integer|between:1,5',
            'review_text'  => 'sometimes|required|string',
        ]);

        // Update data di database
        $review->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Review berhasil diperbarui',
            'data'    => $review
        ], 200);
    }

    // 5. DELETE (Menghapus ulasan dari database)
    public function destroy(Request $request, $id)
    {
        $review = Review::find($id);

        if (!$review) {
            return response()->json([
                'success' => false,
                'message' => 'Review tidak ditemukan'
            ], 404);
        }

        if (! $this->canManageReview($request, $review)) {
            return response()->json([
                'success' => false,
                'message' => 'Kamu tidak boleh menghapus review ini'
            ], 403);
        }

        // Hapus dari database
        $review->delete();

        return response()->json([
            'success' => true,
            'message' => 'Review berhasil dihapus'
        ], 200);
    }

    private function canManageReview(Request $request, Review $review): bool
    {
        $user = $request->user();

        return $user?->role === 'admin' || $review->user_id === $user?->id;
    }
}
