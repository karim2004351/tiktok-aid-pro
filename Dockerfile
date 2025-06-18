# مرحلة البناء
FROM node:20-alpine AS builder

WORKDIR /app

# نسخ package.json و package-lock.json لتثبيت الحزم أولًا (لتسريع الكاش)
COPY package.json package-lock.json ./

# تثبيت الحزم فقط
RUN npm ci

# نسخ باقي الملفات
COPY . .

# بناء الfrontend (Vite)
RUN npm run build:client

# بناء الbackend (TypeScript)
RUN npm run build:server

# مرحلة التشغيل
FROM node:20-alpine AS runner

WORKDIR /app

# نسخ فقط ملفات البناء من مرحلة البناء
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# تشغيل التطبيق في وضع الإنتاج
CMD ["node", "dist/server/index.js"]
