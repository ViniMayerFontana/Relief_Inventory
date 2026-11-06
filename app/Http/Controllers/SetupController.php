<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Http\Controllers;

use App\Services\FirstRunService;
use App\Services\PinLoginService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;
use Inertia\Response;
use RuntimeException;

/**
 * First-run setup wizard (/install). Only reachable while FirstRunService says
 * the instance needs setup; afterwards both routes just send people to /login.
 * If RI_SETUP_CODE is configured, the code must be supplied — the hardening
 * for an instance reachable from the internet before its owner gets to it.
 */
class SetupController extends Controller
{
    public function show(FirstRunService $firstRun): Response|RedirectResponse
    {
        if (! $firstRun->needsSetup()) {
            return redirect()->route('login');
        }

        return Inertia::render('Setup/FirstRun', [
            'codeRequired' => filled(config('app.setup_code')),
        ]);
    }

    public function store(Request $request, FirstRunService $firstRun, PinLoginService $pinLogin): RedirectResponse
    {
        if (! $firstRun->needsSetup()) {
            return redirect()->route('login');
        }

        $data = $request->validate([
            'first_name' => ['required', 'string', 'max:255'],
            'last_name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:people,email'],
            'password' => ['required', 'confirmed', Password::defaults()],
            'example_data' => ['boolean'],
            // The wizard's three-way choice. Older clients send only example_data.
            'starting_data' => ['nullable', 'in:empty,example,simulation'],
            'setup_code' => [filled(config('app.setup_code')) ? 'required' : 'nullable', 'string'],
        ]);

        if (filled(config('app.setup_code')) && ! hash_equals((string) config('app.setup_code'), (string) $request->input('setup_code'))) {
            throw ValidationException::withMessages(['setup_code' => 'O código de configuração está incorreto.']);
        }

        try {
            $startingData = $data['starting_data'] ?? (($data['example_data'] ?? false) ? 'example' : 'empty');
            $result = $firstRun->completeSetup($data, $startingData === 'example', $startingData === 'simulation');
        } catch (RuntimeException) {
            return redirect()->route('login');
        }

        Auth::login($result['user']);
        $request->session()->regenerate();
        // Same as a real login: this browser earns device trust.
        $pinLogin->grantTrust($pinLogin->currentDevice($request), $result['user']->id);

        // The simulation keeps running after this response; its progress page is the useful place to land.
        if ($result['simulation_started']) {
            return redirect('/setup/testing')->with('status', 'Configuração concluída. O ano simulado do armazém está sendo gerado — isso leva um ou dois minutos.');
        }

        return redirect()->route('dashboard')->with(
            'status',
            $result['demo_failed']
                ? 'Configuração concluída, mas não foi possível carregar os dados iniciais (consulte o log do servidor). Você já pode começar a inserir dados reais.'
                : 'Configuração concluída. Boas-vindas ao Relief Inventory!'
        );
    }
}
