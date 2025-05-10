# Предварительная сборка
FROM golang:1.24.3 AS builder   

# Создание рабочего каталога 
WORKDIR /app

# Копирорвание в /app (./)
COPY go.mod go.sum ./

# Запуск go mod 
RUN go mod download

# Копирование всех остальных файлов
COPY . .  

# Сборка бинарника
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/main .

# Формируем конечный образ без временных файлов
FROM alpine:latest

WORKDIR /app

# Копируем из /app builder в текущую (/app)
COPY --from=builder /app/main .
COPY --from=builder /app/tracker.db .  

# Запускаем приложение
CMD ["./main"]
