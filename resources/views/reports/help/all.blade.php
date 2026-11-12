{{-- Every Help guide in one PDF (HelpReportController::allBuilder): a contents list, then each
     guide's own content section on a new page. $guides is [['title', 'content'], ...]. --}}
@extends('reports.help.layout')

@section('title', __('help.all_guides'))

@section('content')
    <style>
        .guide { page-break-before: always; }
        .contents li { margin-bottom: 4px; }
    </style>

    <div class="section">
        <h2>{{ __('help.contents') }}</h2>
        <ol class="contents">
            @foreach ($guides as $guide)
                <li>{{ $guide['title'] }}</li>
            @endforeach
        </ol>
    </div>

    @foreach ($guides as $guide)
        <div class="guide">
            <h1>{{ $guide['title'] }}</h1>
            {!! $guide['content'] !!}
        </div>
    @endforeach
@endsection
