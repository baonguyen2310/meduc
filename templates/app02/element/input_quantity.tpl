<div nh-quantity-product="wrap" class="product-quantity">
    <span nh-quantity-product="subtract" class="btn-quantity">
        <i class="iconsax isax-minus-cirlce"></i>
    </span>

    <input nh-quantity-product="quantity" value="{if !empty($quantity)}{$quantity}{else}1{/if}" class="text-center quantity-input events-none" type="text" />

    <span nh-quantity-product="add" class="btn-quantity">
        <i class="iconsax isax-add-circle"></i>
    </span>
</div>