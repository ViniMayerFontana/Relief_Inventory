<?php

use Illuminate\Support\Facades\Validator;

test('Brazilian Portuguese is the application locale and validation language', function () {
    expect(app()->getLocale())->toBe('pt_BR');

    $errors = Validator::make([], ['name' => 'required'])->errors();

    expect($errors->first('name'))->toBe('O campo nome é obrigatório.');
});
