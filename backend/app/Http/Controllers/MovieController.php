<?php

namespace App\Http\Controllers;

use App\Models\Movie;
use Illuminate\Http\Request;

class MovieController extends Controller
{
    private function ensureAdmin(Request $request)
    {
        if ($request->user()?->role !== 'admin') {
            abort(403, 'Hanya admin yang boleh mengelola movie.');
        }
    }

    public function index()
    {
        return response()->json([
            'success' => true,
            'message' => 'Daftar movie berhasil diambil',
            'data' => Movie::latest()->get(),
        ]);
    }

    public function store(Request $request)
    {
        $this->ensureAdmin($request);

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'type' => 'required|in:film,drama',
            'genre' => 'required|string|max:255',
            'release_year' => 'required|integer|min:1900|max:2100',
            'poster_url' => 'nullable|string|max:500',
            'description' => 'nullable|string',
        ]);

        $movie = Movie::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Movie berhasil ditambahkan',
            'data' => $movie,
        ], 201);
    }

    public function update(Request $request, Movie $movie)
    {
        $this->ensureAdmin($request);

        $data = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'type' => 'sometimes|required|in:film,drama',
            'genre' => 'sometimes|required|string|max:255',
            'release_year' => 'sometimes|required|integer|min:1900|max:2100',
            'poster_url' => 'nullable|string|max:500',
            'description' => 'nullable|string',
        ]);

        $movie->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Movie berhasil diperbarui',
            'data' => $movie,
        ]);
    }

    public function destroy(Request $request, Movie $movie)
    {
        $this->ensureAdmin($request);

        $movie->delete();

        return response()->json([
            'success' => true,
            'message' => 'Movie berhasil dihapus',
        ]);
    }
}
