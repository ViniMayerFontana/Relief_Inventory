<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Support;

/**
 * Design Votes: the polls people vote on at /vote/{slug} to choose between UX designs. Each option is a live demo
 * (a Vue component registered under the same slug and key in resources/js/DesignPolls/index.js), so a poll is
 * defined here in code, not in an admin page. Only whether a poll is open, and the votes, are in the database
 * (design_polls / design_poll_votes), plus any free-form ideas people send from the page (design_poll_ideas — about
 * this question or anything else). Adding a poll: an entry here, its demo components, and a design_polls row
 * (a migration, created closed).
 */
class DesignPolls
{
    public const POLLS = [
        'delivery-days' => [
            'title' => 'Dias de entrega em um pedido',
            'question' => 'Qual destas formas de escolher os dias de entrega faz mais sentido para você?',
            'intro' => 'Quando uma entidade parceira solicita uma entrega, registramos em quais dias ela pode recebê-la. Alguns dias podem ser '
                .'melhores que outros: uma entidade pode aceitar terça, quarta ou quinta, mas preferir terça. '
                .'Experimente cada opção abaixo — toque nos dias como se estivesse fazendo um pedido — e escolha a que preferir.',
            'options' => [
                'cycle' => [
                    'label' => 'Toque para alternar',
                    'description' => 'Cada toque alterna entre: não pode → pode aceitar → preferencial (★) → não pode.',
                ],
                'star' => [
                    'label' => 'Selecione e marque',
                    'description' => 'Toque nos dias em que a entidade parceira pode receber; depois, toque na ☆ de um dia para marcá-lo como preferencial.',
                ],
                'grid' => [
                    'label' => 'Grade de dias',
                    'description' => 'Uma linha por dia. Escolha Não pode, Pode ou Preferencial para cada um.',
                ],
            ],
        ],
    ];

    public static function find(string $slug): ?array
    {
        return isset(self::POLLS[$slug]) ? ['slug' => $slug] + self::POLLS[$slug] : null;
    }

    /** @return array<int, array> every poll, in registry order */
    public static function all(): array
    {
        return array_map(fn ($slug) => self::find($slug), array_keys(self::POLLS));
    }
}
