<?php
declare(strict_types=1);

namespace App\Model\Behavior;

use ArrayObject;
use Cake\Event\EventInterface;
use Cake\ORM\Behavior;
use Cake\ORM\Query;

/** Imported exam content remains private even when its draft/status is changed. */
class StaffExamVisibilityBehavior extends Behavior
{
    protected $_defaultConfig = ['scope' => 'quiz', 'field' => 'id'];

    public function beforeFind(EventInterface $event, Query $query, ArrayObject $options, $primary): void
    {
        if (defined('MEDUC_EXAM_STAFF') && MEDUC_EXAM_STAFF) {
            return;
        }
        $scope = $this->getConfig('scope');
        $table = $scope === 'course' ? 'exam_prep_courses' : 'quiz_exam_metadata';
        $key = $scope === 'course' ? 'product_id' : 'quiz_id';
        $field = $this->_table->aliasField($this->getConfig('field'));
        $query->where("NOT EXISTS (SELECT 1 FROM {$table} private_exam WHERE private_exam.{$key} = {$field} AND private_exam.staff_only = 1)");
    }
}
