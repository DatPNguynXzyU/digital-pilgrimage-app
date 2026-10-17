# Node.js 22
FROM node:22-alpine

# Thư mục làm việc trong container
WORKDIR /app

# Môi trường chạy backend
ENV NODE_ENV=production

# Sao chép khai báo thư viện
COPY package.json package-lock.json ./

# Cài các dependency cần cho backend
RUN npm ci --omit=dev && npm cache clean --force

# Sao chép mã nguồn và dữ liệu dự án
COPY --chown=node:node . .

# Tạo thư mục upload ảnh và cấp quyền
RUN mkdir -p /app/img/avatars \
    && chown -R node:node /app/img/avatars

# Chạy bằng user không phải root
USER node

# Backend lắng nghe cổng 3000
EXPOSE 3000

# Khởi động Express
CMD ["node", "src/server.js"]

