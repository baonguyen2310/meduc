<?php
declare(strict_types=1);

namespace App\Mailer\Transport;

use Cake\Core\Exception\Exception;
use Cake\Mailer\AbstractTransport;
use Cake\Mailer\Message;

/** Deliver existing Cake mail templates through the Resend HTTPS API. */
class ResendTransport extends AbstractTransport
{
    protected $_defaultConfig = ['apiKey' => '', 'timeout' => 10];

    public function send(Message $message): array
    {
        $this->checkRecipient($message);
        $from = $this->addresses($message->getFrom());
        if (count($from) !== 1) {
            throw new Exception('Email delivery requires one sender.');
        }
        if ($message->getAttachments()) {
            throw new Exception('Attachments are not configured for Resend delivery.');
        }

        $payload = [
            'from' => $from[0],
            'to' => $this->addresses($message->getTo()),
            'subject' => $message->getOriginalSubject(),
        ];
        foreach (['cc' => $message->getCc(), 'bcc' => $message->getBcc(), 'reply_to' => $message->getReplyTo()] as $field => $addresses) {
            if ($addresses) {
                $payload[$field] = $this->addresses($addresses);
            }
        }
        if ($message->getBodyHtml() !== null && $message->getBodyHtml() !== '') {
            $payload['html'] = $message->getBodyHtml();
        }
        if ($message->getBodyText() !== null && $message->getBodyText() !== '') {
            $payload['text'] = $message->getBodyText();
        }

        $result = $this->deliverPayload($payload);

        return [
            'headers' => $message->getHeadersString(['from', 'to', 'cc', 'replyTo', 'subject']),
            'message' => implode("\r\n", (array)$message->getBody()),
            'resend_id' => $result['id'],
        ];
    }

    private function addresses(array $addresses): array
    {
        $result = [];
        foreach ($addresses as $email => $name) {
            $name = (string)$name;
            if (preg_match('/=\?[^?]+\?[bq]\?/i', $name)) {
                $decoded = iconv_mime_decode($name, ICONV_MIME_DECODE_CONTINUE_ON_ERROR, 'UTF-8');
                $name = $decoded !== false ? $decoded : $name;
            }
            $name = str_replace(["\r", "\n"], ' ', $name);
            if ($name === $email) {
                $name = '';
            }
            $result[] = $name !== ''
                ? '"' . addcslashes($name, '\\"') . '" <' . $email . '>'
                : $email;
        }

        return $result;
    }

    protected function deliverPayload(array $payload): array
    {
        $apiKey = (string)$this->getConfig('apiKey');
        $body = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if ($apiKey === '' || $body === false) {
            throw new Exception('Email delivery is not configured correctly.');
        }

        $timeout = max(5, min(30, (int)$this->getConfig('timeout')));
        $handle = curl_init('https://api.resend.com/emails');
        curl_setopt_array($handle, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $body,
            CURLOPT_HTTPHEADER => ['Authorization: Bearer ' . $apiKey, 'Content-Type: application/json'],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => min(5, $timeout),
            CURLOPT_TIMEOUT => $timeout,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSL_VERIFYHOST => 2,
            CURLOPT_FOLLOWLOCATION => false,
        ]);
        $response = curl_exec($handle);
        $status = (int)curl_getinfo($handle, CURLINFO_HTTP_CODE);
        curl_close($handle);
        if ($response === false) {
            throw new Exception('Cannot connect to the email delivery service.');
        }

        $result = json_decode($response, true);
        if ($status < 200 || $status >= 300 || !is_array($result) || empty($result['id'])) {
            // Never expose API response bodies, credentials, or OTP contents.
            throw new Exception('Email delivery service rejected the request (HTTP ' . $status . ').');
        }

        return $result;
    }
}
