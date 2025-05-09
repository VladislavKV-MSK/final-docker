# Предварительная сборка
FROM golang:1.24.3 AS builder   

# Создание рабочего каталога 
WORKDIR /app

# Копирорвание в /app (./)
COPY go.mod go.sum ./

# Запуск для go mod и tidy
RUN go mod download && go mod tidy 

# Копирование всех остальных файлов
COPY . . 

# Запуск тестов перед сборкой
RUN go test -v ./... 

# Сборка бинарника
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/main .

# Формируем конечный образ без временных файлов
FROM alpine:latest

# Копируем бинарник и бд из прошлого образа
COPY --from=builder /app/main /app/main
COPY --from=builder /app/tracker.db /app/tracker.db

WORKDIR /app

# Запускаем приложение
CMD ["/app/main"]
