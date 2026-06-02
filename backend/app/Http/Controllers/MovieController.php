<?php

namespace App\Http\Controllers;

use App\Models\Movie;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

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
            'type' => 'required|in:film,series',
            'genre' => 'required|string|max:255',
            'release_year' => 'required|integer|min:1900|max:2100',
            'poster_url' => 'nullable|string|max:500',
            'poster_image' => 'nullable|file|mimes:jpg,jpeg,png,webp|max:4096',
            'description' => 'nullable|string',
        ]);
        unset($data['poster_image']);

        if ($request->hasFile('poster_image')) {
            $directory = public_path('uploads/movie-posters');
            if (! is_dir($directory)) {
                mkdir($directory, 0755, true);
            }

            $file = $request->file('poster_image');
            $filename = Str::uuid().'.'.$file->getClientOriginalExtension();
            $file->move($directory, $filename);
            $data['poster_url'] = asset('uploads/movie-posters/'.$filename);
        }

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
            'type' => 'sometimes|required|in:film,series',
            'genre' => 'sometimes|required|string|max:255',
            'release_year' => 'sometimes|required|integer|min:1900|max:2100',
            'poster_url' => 'nullable|string|max:500',
            'poster_image' => 'nullable|file|mimes:jpg,jpeg,png,webp|max:4096',
            'description' => 'nullable|string',
        ]);
        unset($data['poster_image']);

        if ($request->hasFile('poster_image')) {
            $directory = public_path('uploads/movie-posters');
            if (! is_dir($directory)) {
                mkdir($directory, 0755, true);
            }

            $file = $request->file('poster_image');
            $filename = Str::uuid().'.'.$file->getClientOriginalExtension();
            $file->move($directory, $filename);
            $data['poster_url'] = asset('uploads/movie-posters/'.$filename);
        }

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
