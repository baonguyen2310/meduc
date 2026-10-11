const generateRandomNumber = (length) => {
  const characters = "0123456789";

  let result = "";

  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }

  return result;
};

const cartSession = sessionStorage.getItem("cart");
if(!cartSession) {
    const numberRandom = generateRandomNumber(6);
    sessionStorage.setItem("cart", JSON.stringify({
        cartId: `MEDUC${numberRandom}`,
        cartInfo: {},
        cartProducts: []
    }));
}

// Mini Cart
const nhMiniCartBook = document.querySelector("[nh-mini-cart-book]");
if(nhMiniCartBook) {
    let dataCart = sessionStorage.getItem("cart");
    if(dataCart) {
        dataCart = JSON.parse(sessionStorage.getItem("cart"));
        const dataCartArray = dataCart.cartProducts;
        const nhMiniCartBookQuantity = nhMiniCartBook.querySelector("[nh-mini-cart-book-quantity]");
        nhMiniCartBookQuantity.innerHTML = dataCartArray.length;
    }
}
// End Mini Cart

// Nút thêm sản phẩm vào giỏ hàng
const btnAddCart = document.querySelector(`[dc-btn-action="add-cart"]`);
if(btnAddCart) {
    btnAddCart.addEventListener("click", () => {
        const linkRedirect = btnAddCart.getAttribute("dc-redirect");
        const dataProduct = JSON.parse(btnAddCart.getAttribute("data-product"));
        const quantity = parseInt(document.querySelector(`[nh-quantity-product="quantity"]`).value);
        
        const infoProductAddCart = {
            id: dataProduct.items[0].id,
            name: dataProduct.name,
            image: dataProduct.all_images[0],
            quantity: quantity,
            price: dataProduct.items[0].price,
            price_special: dataProduct.items[0].price_special > 0 ? dataProduct.items[0].price_special : dataProduct.items[0].price,
            url: dataProduct.url,
        };
        
        const dataCart = JSON.parse(sessionStorage.getItem("cart"));
        const dataCartArray = dataCart.cartProducts;
        
        const existProductInCart = dataCartArray.findIndex(item => item.id == dataProduct.items[0].id);
        
        if(existProductInCart != -1) {
            dataCartArray[existProductInCart].quantity = dataCartArray[existProductInCart].quantity + quantity;
        } else {
            dataCartArray.push(infoProductAddCart);
        }
        
        dataCart.cartProducts = dataCartArray;
        
        sessionStorage.setItem("cart", JSON.stringify(dataCart));
        
        window.location.href = linkRedirect;
    });
}
// Hết Nút thêm sản phẩm vào giỏ hàng

// Insert data to input-cart-products
const insertInputCartProducts = () => {
    const inputCartProducts = document.querySelector("[input-cart-products]");
    const dataCart = JSON.parse(sessionStorage.getItem("cart"));
    const dataCartArray = dataCart.cartProducts;
    
    const newArray = dataCartArray.map(item => {
        return {
            id: item.id,
            quantity: item.quantity,
            name: item.name
        };
    });
    
    inputCartProducts.value = JSON.stringify(newArray);
}
// End Insert data to input-cart-products

// Insert cartID
const insertInputCartId = () => {
    const inputCartId = document.querySelector("[input-cart-id]");
    const dataCart = JSON.parse(sessionStorage.getItem("cart"));
    inputCartId.value = dataCart.cartId;
}
// End Insert cartID

// Tính tổng
const funcPriceTotal = () => {
    const dataCart = JSON.parse(sessionStorage.getItem("cart"));
    const dataCartArray = dataCart.cartProducts;
    const priceTotal = dataCartArray.reduce((total, item) => total + item.price_special*item.quantity, 0);
    const elePriceTotal = document.querySelector("[price-total]");
    elePriceTotal.innerHTML = priceTotal.toLocaleString(); 
}
// Hết Tính tổng


// Change input
const funcChangeInput = () => {
    const formContact = document.querySelector("[nh-form-contact]");
    const dataCartDefault = JSON.parse(sessionStorage.getItem("cart"));
    
    const full_name = formContact.querySelector("#full_name");
    full_name.value = dataCartDefault.cartInfo.fullName || "";
    full_name.addEventListener("blur", () => {
        const dataCart = JSON.parse(sessionStorage.getItem("cart"));
        dataCart.cartInfo.fullName = full_name.value;
        sessionStorage.setItem("cart", JSON.stringify(dataCart));
    });
    
    const phone = formContact.querySelector("#phone");
    phone.value = dataCartDefault.cartInfo.phone || "";
    phone.addEventListener("blur", () => {
        const dataCart = JSON.parse(sessionStorage.getItem("cart"));
        dataCart.cartInfo.phone = phone.value;
        sessionStorage.setItem("cart", JSON.stringify(dataCart));
    });
    
    const email = formContact.querySelector("#email");
    email.value = dataCartDefault.cartInfo.email || "";
    email.addEventListener("blur", () => {
        const dataCart = JSON.parse(sessionStorage.getItem("cart"));
        dataCart.cartInfo.email = email.value;
        sessionStorage.setItem("cart", JSON.stringify(dataCart));
    });
    
    const address = formContact.querySelector("#address");
    address.value = dataCartDefault.cartInfo.address || "";
    address.addEventListener("blur", () => {
        const dataCart = JSON.parse(sessionStorage.getItem("cart"));
        dataCart.cartInfo.address = address.value;
        sessionStorage.setItem("cart", JSON.stringify(dataCart));
    });
    
    const note = formContact.querySelector("#note");
    note.value = dataCartDefault.cartInfo.note || "";
    note.addEventListener("blur", () => {
        const dataCart = JSON.parse(sessionStorage.getItem("cart"));
        dataCart.cartInfo.note = note.value;
        sessionStorage.setItem("cart", JSON.stringify(dataCart));
    });
};
// End Change input

// dcCheckout
const dcCheckout = document.querySelector("[dc-checkout]");

if(dcCheckout) {
    const dataCart = JSON.parse(sessionStorage.getItem("cart"));
    const dataCartArray = dataCart.cartProducts;
    
    const paymentCod = dcCheckout.querySelector("#payment-cod");
    paymentCod.addEventListener("click", () => {
        dcCheckout.querySelector(".inner-info-bank").classList.remove("show");
    });
    
    const paymentBank = dcCheckout.querySelector("#payment-bank");
    paymentBank.addEventListener("click", () => {
        dcCheckout.querySelector(".inner-info-bank").classList.add("show");
    });
    
    const boxCartId = dcCheckout.querySelectorAll(".inner-cart-id");
    boxCartId.forEach(item => {
        item.innerHTML = ` ${dataCart.cartId}`;
    });
    
    // Insert cartId
    insertInputCartId();
    // End Insert cartId
    
    // Draw Product List
    const eleProductList = dcCheckout.querySelector("[product-list]");
    
    if(dataCartArray.length == 0) {
        dcCheckout.querySelector("[nh-form-contact]").style.display = "none";
        eleProductList.innerHTML = `Giỏ hàng trống`;
    } else {
        const htmlProducts = dataCartArray.map((item, index) => (
            `
                <div class="inner-product-item" data-id="${item.id}">
                    <div class="inner-image">
                        <img src="https://cdn.meduc.vn${item.image}" />
                    </div>
                    <div class="inner-content">
                        <div class="inner-name">
                            <a href="${item.url}">${item.name}</a>
                        </div>
                        <div class="inner-price">
                            <div class="inner-price-new"><span>${item.price_special.toLocaleString()}</span> <small>VND</small></div>
                            <div class="inner-price-old"><span>${item.price.toLocaleString()}</span> <small>VND</small></div>
                        </div>
                        <div class="inner-quantity">Số lượng: <span>${item.quantity}</span></div>
                        <div class="inner-delete" title="Xóa" btn-delete="${item.id}">
                            <i class="fa-regular fa-trash-can"></i>
                        </div>
                    </div>
                </div>
            `
        ));
        
        eleProductList.innerHTML = htmlProducts.join("");
    }
    // End Draw Product List
    
    // Tính tổng
    funcPriceTotal();
    // Hết Tính tổng
    
    // Insert data to input-cart-products
    insertInputCartProducts();
    // End Insert data to input-cart-products
    
    // Nút xóa
    const listBtnDelete = dcCheckout.querySelectorAll("[btn-delete]");
    if(listBtnDelete.length > 0) {
        listBtnDelete.forEach(button => {
            button.addEventListener("click", () => {
                const dataCart = JSON.parse(sessionStorage.getItem("cart"));
                const dataCartArray = dataCart.cartProducts;
                const productIdDelete = button.getAttribute("btn-delete");
                const newArrayProduct = dataCartArray.filter(item => item.id != productIdDelete);
                
                dataCart.cartProducts = newArrayProduct;
                
                sessionStorage.setItem("cart", JSON.stringify(dataCart));
                
                const eleProductDelete = button.closest(".inner-product-item");
                eleProductList.removeChild(eleProductDelete);
                
                funcPriceTotal();
                
                if(newArrayProduct.length == 0) {
                    dcCheckout.querySelector("[nh-form-contact]").style.display = "none";
                    eleProductList.innerHTML = `Giỏ hàng trống`;
                }
                
                insertInputCartProducts();
            });
        });
    }
    // Hết Nút xóa
    
    // Change input
    funcChangeInput();
    // End Change input
}
// End dcCheckout

// Trang đặt hàng thành công
// const dcOrderSuccess = document.querySelector("[dc-order-success]");
// if(dcOrderSuccess) {
//     const urlParams = new URLSearchParams(window.location.search);
//     const paramCartId = urlParams.get("cartId");
    
//     const dataCart = JSON.parse(sessionStorage.getItem("cart"));
//     const cartId = dataCart.cartId;
    
//     if(cartId == paramCartId) {
//         localStorage.setItem(cartId, sessionStorage.getItem("cart"));
//         sessionStorage.removeItem("cart");
//     }
    
    
//     const infoCart = JSON.parse(localStorage.getItem(paramCartId));
//     if(infoCart) {
//         // Hiển thị mã đơn hàng
//         document.querySelector("[cart-id]").innerHTML = infoCart.cartId || "";
//         // Hết Hiển thị mã đơn hàng
        
//         // Hiển thị thông tin khách hàng
//         document.querySelector("[value-name]").innerHTML = infoCart.cartInfo.fullName || "";
//         document.querySelector("[value-phone]").innerHTML = infoCart.cartInfo.phone || "";
//         document.querySelector("[value-email]").innerHTML = infoCart.cartInfo.email || "";
//         document.querySelector("[value-address]").innerHTML = infoCart.cartInfo.address || "";
//         document.querySelector("[value-note]").innerHTML = infoCart.cartInfo.note || "";
//         // Hết Hiển thị thông tin khách hàng
        
//         // Hiển thị danh sách sản phẩm đã đặt
//         const eleProductList = document.querySelector("[product-list]");

//         const htmlProducts = infoCart.cartProducts.map((item, index) => (
//             `
//                 <div class="inner-product-item" data-id="${item.id}">
//                     <div class="inner-image">
//                         <img src="https://cdn.meduc.vn${item.image}" />
//                     </div>
//                     <div class="inner-content">
//                         <div class="inner-name">
//                             <a href="${item.url}">${item.name}</a>
//                         </div>
//                         <div class="inner-price">
//                             <div class="inner-price-new"><span>${item.price_special.toLocaleString()}</span> <small>VND</small></div>
//                             <div class="inner-price-old"><span>${item.price.toLocaleString()}</span> <small>VND</small></div>
//                         </div>
//                         <div class="inner-quantity">Số lượng: <span>${item.quantity}</span></div>
//                     </div>
//                 </div>
//             `
//         ));
        
//         eleProductList.innerHTML = htmlProducts.join("");
        
        
//         const priceTotal = infoCart.cartProducts.reduce((total, item) => total + item.price_special*item.quantity, 0);
//         const elePriceTotal = document.querySelector("[price-total]");
//         elePriceTotal.innerHTML = priceTotal.toLocaleString();
//         // Hết Hiển thị danh sách sản phẩm đã đặt
//     }
// }


const dcOrderSuccess = document.querySelector("[dc-order-success]");
if(dcOrderSuccess) {
    const urlParams = new URLSearchParams(window.location.search);
    const paramCartId = urlParams.get("cartId");
    
    const dataCart = JSON.parse(sessionStorage.getItem("cart"));
    const cartId = dataCart.cartId;
    
    if(cartId == paramCartId) {
        localStorage.setItem(cartId, sessionStorage.getItem("cart"));
        sessionStorage.removeItem("cart");
    }
    
    fetch(`https://meduc.vn/order-cartid?cartId=${paramCartId}`)
        .then(res => res.json())
        .then(data => {
            if(data) {
                // Hiển thị mã đơn hàng
                document.querySelector("[cart-id]").innerHTML = data.cartId || "";
                // Hết Hiển thị mã đơn hàng
                
                // Hiển thị thông tin khách hàng
                document.querySelector("[value-name]").innerHTML = data.full_name || "";
                document.querySelector("[value-phone]").innerHTML = data.phone || "";
                document.querySelector("[value-email]").innerHTML = data.email || "";
                document.querySelector("[value-address]").innerHTML = data.address || "";
                document.querySelector("[value-note]").innerHTML = data.note || "";
                // Hết Hiển thị thông tin khách hàng
                
                // Hiển thị danh sách sản phẩm đã đặt
                const eleProductList = document.querySelector("[product-list]");
        
                const htmlProducts = JSON.parse(data.cartProducts).map((item, index) => (
                    `
                        <div class="inner-product-item" data-id="${item.id}">
                            <div class="inner-image">
                                <img src="https://cdn.meduc.vn${item.image}" />
                            </div>
                            <div class="inner-content">
                                <div class="inner-name">
                                    <a href="${item.url}">${item.name}</a>
                                </div>
                                <div class="inner-price">
                                    <div class="inner-price-new"><span>${item.price_special.toLocaleString()}</span> <small>VND</small></div>
                                    <div class="inner-price-old"><span>${item.price.toLocaleString()}</span> <small>VND</small></div>
                                </div>
                                <div class="inner-quantity">Số lượng: <span>${item.quantity}</span></div>
                            </div>
                        </div>
                    `
                ));
                
                eleProductList.innerHTML = htmlProducts.join("");
                
                
                const priceTotal = JSON.parse(data.cartProducts).reduce((total, item) => total + item.price_special*item.quantity, 0);
                const elePriceTotal = document.querySelector("[price-total]");
                elePriceTotal.innerHTML = priceTotal.toLocaleString();
                // Hết Hiển thị danh sách sản phẩm đã đặt
            }
        })
}
// Hết Trang đặt hàng thành công