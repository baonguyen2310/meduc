(() => {
  "use strict";

  const videoSection = document.querySelector("body.meduc-home-v2 > .mhi-voices");
  if (!videoSection) return;

  // Sample copy and generated portraits until approved learner feedback is available.
  const stories = [
    {
      name: "Mai Anh",
      context: "Sinh viên Y khoa năm 3",
      quote: "Từ khi chia mục tiêu thành từng phần nhỏ, mình không còn bị ngợp trước lượng kiến thức Y khoa. Học xong một chủ đề, mình biết rõ cần ôn lại điều gì.",
      image: "/hero-light/assets/images/testimonials/hoc-vien-01.jpg",
    },
    {
      name: "Minh Quân",
      context: "Sinh viên Y khoa năm 4",
      quote: "Điều mình cần nhất là hiểu vì sao một đáp án đúng. Khi kiến thức được giải thích mạch lạc và gắn với tình huống lâm sàng, việc ôn tập trở nên thú vị hơn.",
      image: "/hero-light/assets/images/testimonials/hoc-vien-02.jpg",
    },
    {
      name: "Khánh Linh",
      context: "Sinh viên Y khoa năm 2",
      quote: "Mình thích cảm giác có thể quay lại bài học bất cứ lúc nào. Nhịp học linh hoạt giúp mình cân bằng giữa thực tập và việc củng cố kiến thức nền.",
      image: "/hero-light/assets/images/testimonials/hoc-vien-03.jpg",
    },
  ];

  const section = document.createElement("section");
  section.className = "mhi-testimonials";
  section.setAttribute("aria-labelledby", "mhi-testimonials-title");
  section.innerHTML = `
    <div class="mhi-testimonials-shell">
      <div class="mhi-testimonials-heading">
        <p>CÂU CHUYỆN NGƯỜI HỌC</p>
        <h2 id="mhi-testimonials-title">Góc chia sẻ của người học.</h2>
        <span>Nội dung và chân dung minh họa</span>
      </div>
      <div class="mhi-testimonials-stage" aria-live="polite"></div>
      <div class="mhi-testimonials-dots" aria-label="Chọn cảm nhận"></div>
    </div>`;

  const stage = section.querySelector(".mhi-testimonials-stage");
  const dots = section.querySelector(".mhi-testimonials-dots");
  stories.forEach((story, index) => {
    const slide = document.createElement("article");
    slide.className = "mhi-testimonials-slide";
    slide.hidden = index !== 0;

    const photo = document.createElement("div");
    photo.className = "mhi-testimonials-photo";
    const image = document.createElement("img");
    image.src = story.image;
    image.alt = `Chân dung minh họa học viên ${story.name}`;
    image.loading = "lazy";
    image.decoding = "async";
    photo.append(image);

    const card = document.createElement("div");
    card.className = "mhi-testimonials-card";
    const quoteMark = document.createElement("span");
    quoteMark.className = "mhi-testimonials-quote-mark";
    quoteMark.setAttribute("aria-hidden", "true");
    quoteMark.textContent = "“";
    const quote = document.createElement("blockquote");
    quote.textContent = story.quote;
    const byline = document.createElement("p");
    byline.className = "mhi-testimonials-byline";
    const name = document.createElement("strong");
    name.textContent = story.name;
    const context = document.createElement("span");
    context.textContent = story.context;
    byline.append(name, context);
    card.append(quoteMark, quote, byline);
    slide.append(photo, card);
    stage.append(slide);

    const dot = document.createElement("button");
    dot.type = "button";
    dot.className = "mhi-testimonials-dot";
    dot.setAttribute("aria-label", `Xem chia sẻ minh họa ${index + 1}`);
    dot.setAttribute("aria-current", index === 0 ? "true" : "false");
    dot.addEventListener("click", () => show(index));
    dots.append(dot);
  });

  const previous = document.createElement("button");
  previous.type = "button";
  previous.className = "mhi-testimonials-arrow mhi-testimonials-prev";
  previous.setAttribute("aria-label", "Chia sẻ trước");
  previous.innerHTML = '<span aria-hidden="true">‹</span>';
  const next = document.createElement("button");
  next.type = "button";
  next.className = "mhi-testimonials-arrow mhi-testimonials-next";
  next.setAttribute("aria-label", "Chia sẻ tiếp theo");
  next.innerHTML = '<span aria-hidden="true">›</span>';
  stage.append(previous, next);

  let active = 0;
  function show(index) {
    active = (index + stories.length) % stories.length;
    [...stage.querySelectorAll(".mhi-testimonials-slide")].forEach((slide, i) => { slide.hidden = i !== active; });
    [...dots.children].forEach((dot, i) => dot.setAttribute("aria-current", i === active ? "true" : "false"));
  }
  previous.addEventListener("click", () => show(active - 1));
  next.addEventListener("click", () => show(active + 1));
  section.addEventListener("keydown", (event) => {
    if (event.key === "ArrowLeft") { event.preventDefault(); show(active - 1); }
    if (event.key === "ArrowRight") { event.preventDefault(); show(active + 1); }
  });

  videoSection.after(section);
})();
