<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // Create the "uses" table
        Schema::create('uses', function (Blueprint $table) {
            $table->id();
            $table->string('use')->unique();
            $table->timestamps();
        });

        // Os usos pré-definidos migram para pt-BR em
        // 2026_11_19_000002_seed_location_uses_pt_br.php (legado EN em
        // disabled_en/backup_en_uses.php).

        // Modify the "locations" table
        Schema::table('locations', function (Blueprint $table) {
            $table->integer('PullSequence')->after('id');
            $table->string('Route')->after('PullSequence');
            $table->string('Block')->after('Route');
            $table->string('Aisle')->after('Block');
            $table->string('Lane')->after('Aisle');
            $table->string('Stack')->after('Lane');
            $table->unsignedBigInteger('use_id')->nullable()->after('Stack');

            $table->foreign('use_id')->references('id')->on('uses')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // Drop the foreign key and column in "locations"
        Schema::table('locations', function (Blueprint $table) {
            $table->dropForeign(['use_id']);
            $table->dropColumn([
                'PullSequence',
                'Route',
                'Block',
                'Aisle',
                'Lane',
                'Stack',
                'use_id',
            ]);
        });

        // Drop the "uses" table
        Schema::dropIfExists('uses');
    }
};
