-- 1. Crear base de datos

    Create database db_Lavanderias_GT;
    go

    use db_Lavanderias_GT;
    go

--2. Crear las tablas

    Create Table Tbl_Sucursales
    (
        CodigoSucursal Int Identity(1,1) Primary Key,
        NombreSucursal Varchar(100) Not Null Unique,
        Direccion Varchar(200) Not Null,
        Municipio Varchar(80) Not Null,
        Departamento Varchar(80) Not Null,
        Telefono Varchar(20) Not Null Unique,
        HorarioAtencion Varchar(120) Not Null,
        Estado Bit Not Null
    );

    Create Table Tbl_Roles
    (
        CodigoRol Int Identity(1,1) Primary Key,
        NombreRol Varchar(60) Not Null Unique,
        Descripcion Varchar(200),
        Estado Bit Not Null
    );

    Create Table Tbl_Modulos
    (
        CodigoModulo Int Identity(1,1) Primary Key,
        NombreModulo Varchar(60) Not Null Unique,
        NombreFormulario Varchar(80) Not Null Unique,
        Descripcion Varchar(200),
        Orden Int Not Null,
        Estado Bit Not Null,

        Check (Orden > 0)
    );

    Create Table Tbl_PermisosRol
    (
        CodigoPermiso Int Identity(1,1) Primary Key,
        CodigoRol Int Not Null,
        CodigoModulo Int Not Null,
        PuedeConsultar Bit Not Null,
        PuedeAgregar Bit Not Null,
        PuedeEditar Bit Not Null,
        PuedeEliminar Bit Not Null,
        PuedeBuscar Bit Not Null,
        Estado Bit Not Null,

        Unique (CodigoRol, CodigoModulo),
        Foreign Key (CodigoRol) References Tbl_Roles(CodigoRol),
        Foreign Key (CodigoModulo) References Tbl_Modulos(CodigoModulo)
    );

    Create Table Tbl_Usuarios
    (
        CodigoUsuario Int Identity(1,1) Primary Key,
        CodigoSucursal Int Not Null,
        CodigoRol Int Not Null,
        NombreUsuario Varchar(50) Not Null Unique,
        NombreCompleto Varchar(120) Not Null,
        Correo Varchar(120) Not Null Unique,
        Salt Varchar(32) Not Null,
        ClaveHash Varchar(64) Not Null,
        FechaCreacion DateTime Not Null,
        UltimoAcceso DateTime NULL,
        IntentosFallidos Int Not Null,
        Estado Bit Not Null,

        Check (IntentosFallidos >= 0),
        Check (Len(ClaveHash) = 64),
        Foreign Key (CodigoSucursal) References Tbl_Sucursales(CodigoSucursal),
        Foreign Key (CodigoRol) References Tbl_Roles(CodigoRol)
    );

    Create Table Tbl_BitacoraAcceso
    (
        CodigoBitacora Int Identity(1,1) Primary Key,
        CodigoUsuario Int NULL,
        NombreUsuarioIntento Varchar(50) Not Null,
        FechaHora DateTime Not Null,
        Resultado Varchar(20) Not Null,
        Equipo Varchar(100) NULL,
        Observaciones Varchar(200) NULL,

        Check (Resultado In ('EXITOSO', 'FALLIDO', 'BLOQUEADO')),
        Foreign Key (CodigoUsuario) References Tbl_Usuarios(CodigoUsuario)
    );

    Create Table Tbl_Clientes
    (
        CodigoCliente Int Identity(1,1) Primary Key,
        Nombres Varchar(80) Not Null,
        Apellidos Varchar(80) Not Null,
        NIT Varchar(15) Not Null,
        DPI Varchar(13) NULL Unique,
        Telefono Varchar(20) Not Null,
        Correo Varchar(120) NULL,
        Direccion Varchar(200) NULL,
        FechaRegistro Date Not Null,
        Estado Bit Not Null
    );

    Create Table Tbl_TiposPrenda
    (
        CodigoTipoPrenda Int Identity(1,1) Primary Key,
        NombreTipoPrenda Varchar(80) Not Null Unique,
        Descripcion Varchar(200),
        Estado Bit Not Null
    );

    Create Table Tbl_Servicios
    (
        CodigoServicio Int Identity(1,1) Primary Key,
        NombreServicio Varchar(80) Not Null Unique,
        Descripcion Varchar(200),
        TiempoEstimadoHoras Int Not Null,
        Estado Bit Not Null,

        Check (TiempoEstimadoHoras > 0)
    );

    Create Table Tbl_Tarifas
    (
        CodigoTarifa Int Identity(1,1) Primary Key,
        CodigoTipoPrenda Int Not Null,
        CodigoServicio Int Not Null,
        Precio Decimal(10,2) Not Null,
        FechaVigencia Date Not Null,
        FechaFin Date NULL,
        Estado Bit Not Null,

        Unique (CodigoTipoPrenda, CodigoServicio, FechaVigencia),
        Unique (CodigoTarifa, CodigoTipoPrenda, CodigoServicio),
        Check (Precio > 0),
        Check (FechaFin Is Null Or FechaFin >= FechaVigencia),
        Foreign Key (CodigoTipoPrenda) References Tbl_TiposPrenda(CodigoTipoPrenda),
        Foreign Key (CodigoServicio) References Tbl_Servicios(CodigoServicio)
    );

    Create Table Tbl_EstadosProceso
    (
        CodigoEstadoProceso Int Identity(1,1) Primary Key,
        NombreEstado Varchar(60) Not Null Unique,
        Descripcion Varchar(200),
        Orden Int Not Null Unique,
        Estado Bit Not Null,

        Check (Orden > 0)
    );

    Create Table Tbl_Recepciones
    (
        CodigoRecepcion Int Identity(1,1) Primary Key,
        CodigoSucursal Int Not Null,
        CodigoCliente Int Not Null,
        CodigoUsuario Int Not Null,
        NumeroRecepcion Varchar(20) Not Null Unique,
        FechaHoraRecepcion DateTime Not Null,
        FechaEstimadaEntrega Date Not Null,
        Total Decimal(10,2) Not Null,
        Observaciones Varchar(300) NULL,
        Estado Bit Not Null,

        Check (Total >= 0),
        Check (FechaEstimadaEntrega >= Cast(FechaHoraRecepcion As Date)),
        Foreign Key (CodigoSucursal) References Tbl_Sucursales(CodigoSucursal),
        Foreign Key (CodigoCliente) References Tbl_Clientes(CodigoCliente),
        Foreign Key (CodigoUsuario) References Tbl_Usuarios(CodigoUsuario)
    );

    Create Table Tbl_DetalleRecepciones
    (
        CodigoDetalle Int Identity(1,1) Primary Key,
        CodigoRecepcion Int Not Null,
        CodigoTarifa Int Not Null,
        CodigoTipoPrenda Int Not Null,
        CodigoServicio Int Not Null,
        Cantidad Int Not Null,
        PrecioUnitario Decimal(10,2) Not Null,
        Subtotal Decimal(10,2) Not Null,
        Caracteristicas Varchar(150) NULL,
        Observaciones Varchar(250) NULL,

        Check (Cantidad > 0),
        Check (PrecioUnitario > 0),
        Check (Subtotal = Cantidad * PrecioUnitario),
        Foreign Key (CodigoRecepcion) References Tbl_Recepciones(CodigoRecepcion) On Delete Cascade,
        Foreign Key (CodigoTarifa, CodigoTipoPrenda, CodigoServicio) References Tbl_Tarifas(CodigoTarifa, CodigoTipoPrenda, CodigoServicio)
    );

    Create Table Tbl_Procesos
    (
        CodigoProceso Int Identity(1,1) Primary Key,
        CodigoRecepcion Int Not Null,
        CodigoEstadoProceso Int Not Null,
        CodigoUsuario Int Not Null,
        FechaProceso Date Not Null,
        HoraProceso Time Not Null,
        Observaciones Varchar(250) NULL,
        Estado Bit Not Null,

        Foreign Key (CodigoRecepcion) References Tbl_Recepciones(CodigoRecepcion),
        Foreign Key (CodigoEstadoProceso) References Tbl_EstadosProceso(CodigoEstadoProceso),
        Foreign Key (CodigoUsuario) References Tbl_Usuarios(CodigoUsuario)
    );

    Create Table Tbl_Entregas
    (
        CodigoEntrega Int Identity(1,1) Primary Key,
        CodigoRecepcion Int Not Null,
        CodigoUsuario Int Not Null,
        FechaEntrega Date Not Null,
        HoraEntrega Time Not Null,
        NombreRecibe Varchar(120) Not Null,
        Observaciones Varchar(250) NULL,
        Estado Bit Not Null,

        Foreign Key (CodigoRecepcion) References Tbl_Recepciones(CodigoRecepcion),
        Foreign Key (CodigoUsuario) References Tbl_Usuarios(CodigoUsuario)
    );


