<?php
declare(strict_types=1);

namespace Admin\View\Helper;

use Cake\View\Helper;
use Cake\Core\Configure;
use Cake\ORM\TableRegistry;
use Cake\Utility\Hash;

class CategoryAdminHelper extends Helper
{   

    public function getListCategoriesForDropdown($params = [])
    {
        $type = !empty($params[TYPE]) ? $params[TYPE] : null;
        $lang = !empty($params[LANG]) ? $params[LANG] : null;
        if(empty($type) || empty($lang)){
            return [];
        }
        
        if(!in_array($type, Configure::read('LIST_TYPE_CATEGORY'))) {
            return [];
        }

        $params[FIELD] = LIST_INFO;
        $params[FILTER][STATUS] = 1;
        $params[FILTER][TYPE] = $type;
        $params[FILTER][LANG] = $lang;
        $params[FILTER][NOT_ID] = !empty($params[NOT_ID]) ? $params[NOT_ID] : null;
        $params[SORT][FIELD] = 'position';
        $params[SORT][SORT] = DESC;

        $categories = TableRegistry::get('Categories')->queryListCategories($params)->nest('id', 'parent_id')->toArray();

        $result = [];
        if(!empty($categories)){
            $result = $this->parseDataCategoryDropdown($categories, 0);
        }
        return $result;
    }

    private function parseDataCategoryDropdown($categories = [], $loop = 0)
    {
        $result = [];
        if(empty($categories)) return $result;

        $loop ++;
        $char = '---- ';
        $char_level = '';

        for ($i = 1; $i < $loop; $i++) {
            $char_level .= $char;
        }

        foreach($categories as $category){           
            if(empty($category['id']) || empty($category['CategoriesContent']->name)) continue;
            $result[$category['id']] = $char_level . $category['CategoriesContent']->name;            
            if(!empty($category['children'])){
                $result += $this->parseDataCategoryDropdown($category['children'], $loop);    
            }
        }

        return $result;
    }

    public function getListCourse($params = [])
    {
        $params[FIELD] = LIST_INFO;
        $params[FILTER][STATUS] = 1;
        $params[FILTER][NOT_ID] = !empty($params[NOT_ID]) ? $params[NOT_ID] : null;
        $params[SORT][FIELD] = 'position';
        $params[SORT][SORT] = DESC;

        $products = TableRegistry::get('Products')
            ->find()
            ->contain([
                'ProductsContent'
            ])
            ->select([
                'Products.id', 
                'ProductsContent.name',
            ])
            ->where([
                'Products.main_category_id' => 50,
                'Products.deleted' => 0
            ])
            ->toArray();

        $result = [];
        if(!empty($products)){
            $result = $this->parseDataProductDropdown($products, 0);
        }
        return $result;
    }

    private function parseDataProductDropdown($products = [], $loop = 0)
    {
        $result = [];
        if(empty($products)) return $result;

        $loop ++;
        $char = '---- ';
        $char_level = '';

        for ($i = 1; $i < $loop; $i++) {
            $char_level .= $char;
        }

        foreach($products as $product){           
            if(empty($product['id']) || empty($product['ProductsContent']->name)) continue;
            $result[$product['id']] = $char_level . $product['ProductsContent']->name;
        }

        return $result;
    }

    public function getListCategoriesForCheckboxList($params = [])
    {
        $type = !empty($params[TYPE]) ? $params[TYPE] : null;
        $lang = !empty($params[LANG]) ? $params[LANG] : null;
        if(empty($type) || empty($lang)){
            return [];
        }

        if(!in_array($type, Configure::read('LIST_TYPE_CATEGORY'))) {
            return [];
        }

        $categories = TableRegistry::get('Categories')->queryListCategories([
            FIELD => LIST_INFO,
            FILTER => [
                STATUS => 1,
                TYPE => $type,
                LANG => $lang,
                NOT_ID => !empty($params[NOT_ID]) ? $params[NOT_ID] : null
            ],
            SORT => [FIELD => 'position', SORT => DESC]
        ])->nest('id', 'parent_id')->toArray();        
        $result = [];
        if(!empty($categories)){
            $result = $this->parseDataCategoryCheckBox($categories, 0);
        }
        return $result;
    }

    private function parseDataCategoryCheckBox($categories = [], $loop = 0)
    {
        $result = [];
        if(empty($categories)) return $result;

        $loop ++;
        foreach($categories as $category){           
            if(empty($category['id']) || empty($category['CategoriesContent']->name)) continue;
            $result[$category['id']] = [
                'name' => $category['CategoriesContent']->name,
                'level' => $loop
            ];
            if(!empty($category['children'])){
                $result += $this->parseDataCategoryCheckBox($category['children'], $loop);    
            }
        }

        return $result;
    }

    public function getAllNameContent($category_id = null)
    {
        if(empty($category_id)) return [];
        $result = TableRegistry::get('Categories')->getAllNameContent($category_id);
        return $result;
    }

    public function getDetailCategory($type = null, $category_id = null, $lang = null, $params = [])
    {
        $table = TableRegistry::get('Categories');
        $category = $table->getDetailCategory($type, $category_id, $lang);

        $result = [];
        if(!empty($category)){
            $result = $table->formatDataCategoryDetail($category, $lang);
        }
        
        return $result;
    }
}
