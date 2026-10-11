{if !empty($all_notifications)}
    {assign var = notification_news value = []}
    {assign var = notification_orders value = []}

    {if !empty($all_notifications.news)}
        {$notification_news = $all_notifications.news}
    {/if}

    {if !empty($all_notifications.orders)}
        {$notification_orders = $all_notifications.orders}
    {/if}

    {if !empty($notification_news.notifications)}
        {foreach from = $notification_news.notifications item = notification}
            {assign var = link value = ''}
            {if !empty($notification.link)}
                {$link = $notification.link}
            {/if}

            <li class="mx-md-20 mx-10 inner-notification border-bottom pb-5 mb-5">
                <a nh-item-notification="{if !empty($notification.id)}{$notification.id}{/if}" nh-time-notification="{if !empty($notification.created)}{$notification.created}{/if}" class="d-flex justify-content-start align-items-start p-10 rounded" href="/{$link}">
                    <div class="mr-15">
                        {if !empty($notification.image)}
                            <img src="{CDN_URL}{$this->Utilities->getThumbs($notification.image, 150)}" class="border rounded-circle image-48x48">
                        {/if}
                    </div>
                    <div class="notification-content">
                        {if !empty($notification.title)}
                            <strong>{$notification.title|escape|truncate:80:" ..."}</strong>
                        {/if}
                        {if !empty($notification.body)}
                            {$notification.body|escape|truncate:80:" ..."}
                        {/if}
                        {if !empty($notification.created)}
                            <br>
                            {assign var = time_format value = $this->Notification->formatTimeClient($notification.created)}
                            {if !empty($time_format.time)}
                                <span class="text-primary font-medium fs-12">
                                {$time_format.time}
                                </span>
                            {/if}
                        {/if}
                    </div>
                </a>
            </li>
        {/foreach}

        {assign var = pagination value = []}
        {if !empty($notification_news.pagination)}
            {$pagination = $notification_news.pagination}
        {/if}

        {if !empty($pagination.pages) && !empty($pagination.page) && $pagination.pages > $pagination.page}
            <div class="mx-md-20 mx-10 text-center mt-10">
                <span class="color-hover cursor-pointer" nh-more-notification="{$pagination.page + 1}">
                    {__d('template', 'xem_them')}
                </span>
            </div>
        {/if}
    {/if}
{/if}