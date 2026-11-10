<?php
declare(strict_types=1);
namespace App\Service;

use Cake\ORM\TableRegistry;

/** Contact details belong to the invoice; edits here do not change the student's profile. */
final class CheckoutContact
{
    public static function customer(int $id): array
    {
        if (!$id) return [];
        return TableRegistry::get('Customers')->find()->where(['id'=>$id, 'deleted'=>0])
            ->enableHydration(false)->first() ?: [];
    }

    public static function profile(array $customer, $contact = []): array
    {
        if (!$customer) return [];
        if ($contact instanceof \Cake\Datasource\EntityInterface) $contact = $contact->toArray();
        if (!is_array($contact)) $contact = [];
        $address = TableRegistry::get('CustomersAddress')->find()->where(['customer_id'=>(int)$customer['id']])
            ->order(['is_default'=>'DESC', 'id'=>'DESC'])->enableHydration(false)->first() ?: [];
        return [
            'full_name'=>(string)(!empty($contact['full_name']) ? $contact['full_name'] : ($customer['full_name'] ?? '')),
            'phone'=>(string)(!empty($contact['phone']) ? $contact['phone'] : ($customer['phone'] ?? '')),
            'email'=>(string)($customer['email'] ?? ''),
            'address'=>(string)(($contact['full_address'] ?? '') ?: ($contact['address'] ?? '') ?: ($address['full_address'] ?? '') ?: ($address['address'] ?? ''))
        ];
    }

    public static function validate(array $data, array $customer, bool $shipping = false): array
    {
        if (empty($customer['id'])) throw new \InvalidArgumentException('Vui lòng đăng nhập để tiếp tục thanh toán.');
        $contact = [
            'full_name'=>trim((string)($data['full_name'] ?? $customer['full_name'] ?? '')),
            'phone'=>trim((string)($data['phone'] ?? $customer['phone'] ?? '')),
            // The email displayed in the form is never accepted from the browser.
            'email'=>trim((string)($customer['email'] ?? ''))
        ];
        if ($contact['full_name'] === '' || mb_strlen($contact['full_name']) > 255)
            throw new \InvalidArgumentException('Vui lòng nhập họ và tên.');
        if (!preg_match('/^[+0-9][0-9 .()-]{7,20}$/', $contact['phone']))
            throw new \InvalidArgumentException('Vui lòng nhập số điện thoại hợp lệ.');
        if (!filter_var($contact['email'], FILTER_VALIDATE_EMAIL))
            throw new \InvalidArgumentException('Vui lòng cập nhật email trong thông tin học viên.');
        if ($shipping) {
            $contact['address'] = trim((string)($data['address'] ?? ''));
            if ($contact['address'] === '' || mb_strlen($contact['address']) > 512)
                throw new \InvalidArgumentException('Vui lòng nhập địa chỉ nhận hàng.');
        }
        return $contact;
    }

    public static function save(int $orderId, array $customer, array $data): array
    {
        $table = TableRegistry::get('OrdersContact');
        $row = $table->find()->where(['order_id'=>$orderId, 'customer_id'=>(int)($customer['id'] ?? 0)])->first();
        if (!$row || empty($customer['id'])) throw new \InvalidArgumentException('Không tìm thấy đơn hàng của bạn.');
        $contact = self::validate($data, $customer);
        $row = $table->patchEntity($row, $contact);
        if (!$table->save($row)) throw new \RuntimeException('Chưa lưu được thông tin thanh toán.');
        return $contact;
    }
}
