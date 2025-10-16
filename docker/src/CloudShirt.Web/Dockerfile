FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY src/CloudShirt.Web/CloudShirt.Web.csproj src/CloudShirt.Web/
RUN dotnet restore src/CloudShirt.Web/CloudShirt.Web.csproj
COPY . .
RUN dotnet publish src/CloudShirt.Web/CloudShirt.Web.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
ENV ASPNETCORE_URLS=http://0.0.0.0:5000 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
EXPOSE 5000
COPY --from=build /app/publish/ .
ENTRYPOINT ["dotnet", "CloudShirt.Web.dll"]
