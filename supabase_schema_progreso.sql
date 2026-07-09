-- =====================================================================
-- ADICIÓN AL ESQUEMA: Progreso de requisitos de estadía
-- Ejecutar en: Supabase Dashboard > SQL Editor
-- (Ejecutar DESPUÉS de supabase_schema.sql)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Campo para saber si el alumno ya tiene su estadía confirmada.
--    Por ahora se activa manualmente desde el Table Editor de Supabase
--    (o desde el flujo de confirmación que se construya más adelante,
--    por ejemplo cuando una empresa/dirección acepte al alumno).
-- ---------------------------------------------------------------------
alter table public.alumnos
  add column if not exists estadia_confirmada boolean not null default false;


-- ---------------------------------------------------------------------
-- 2. Tabla de progreso: un renglón por cada requisito marcado por
--    cada alumno. El id del requisito es un texto fijo (ver progreso.html,
--    constante REQUISITOS) para poder identificarlo desde el frontend.
-- ---------------------------------------------------------------------
create table public.progreso_requisitos (
  alumno_id uuid references public.alumnos(id) on delete cascade,
  requisito_id text not null,
  completado boolean not null default false,
  fecha_completado timestamp with time zone,
  primary key (alumno_id, requisito_id)
);

alter table public.progreso_requisitos enable row level security;

create policy "Alumnos ven su propio progreso"
on public.progreso_requisitos for select
using (auth.uid() = alumno_id);

create policy "Alumnos insertan su propio progreso"
on public.progreso_requisitos for insert
with check (auth.uid() = alumno_id);

create policy "Alumnos actualizan su propio progreso"
on public.progreso_requisitos for update
using (auth.uid() = alumno_id);
