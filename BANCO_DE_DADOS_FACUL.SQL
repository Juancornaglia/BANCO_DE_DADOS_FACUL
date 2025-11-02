CREATE TABLE public.agendamentos (
  id_agendamento bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_cliente uuid NOT NULL,
  id_pet bigint NOT NULL,
  id_loja integer NOT NULL,
  id_servico integer NOT NULL,
  data_hora_inicio timestamp with time zone NOT NULL,
  data_hora_fim timestamp with time zone,
  status character varying NOT NULL DEFAULT 'pendente'::character varying,
  observacoes_cliente text,
  data_criacao timestamp without time zone DEFAULT now(),
  CONSTRAINT agendamentos_pkey PRIMARY KEY (id_agendamento),
  CONSTRAINT agendamentos_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.perfis(id),
  CONSTRAINT agendamentos_id_pet_fkey FOREIGN KEY (id_pet) REFERENCES public.pets(id_pet),
  CONSTRAINT agendamentos_id_loja_fkey FOREIGN KEY (id_loja) REFERENCES public.lojas(id_loja),
  CONSTRAINT agendamentos_id_servico_fkey FOREIGN KEY (id_servico) REFERENCES public.servicos(id_servico)
);
CREATE TABLE public.dias_bloqueados (
  id_bloqueio integer NOT NULL DEFAULT nextval('dias_bloqueados_id_bloqueio_seq'::regclass),
  id_loja integer,
  data_bloqueada date NOT NULL,
  motivo text,
  CONSTRAINT dias_bloqueados_pkey PRIMARY KEY (id_bloqueio),
  CONSTRAINT dias_bloqueados_id_loja_fkey FOREIGN KEY (id_loja) REFERENCES public.lojas(id_loja)
);
CREATE TABLE public.fidelidade_historico (
  id_historico bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_cliente uuid NOT NULL,
  pontos integer NOT NULL,
  tipo character varying NOT NULL,
  id_referencia_pedido bigint,
  id_referencia_agendamento bigint,
  data_criacao timestamp with time zone DEFAULT now(),
  CONSTRAINT fidelidade_historico_pkey PRIMARY KEY (id_historico),
  CONSTRAINT fidelidade_historico_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.perfis(id),
  CONSTRAINT fidelidade_historico_id_referencia_pedido_fkey FOREIGN KEY (id_referencia_pedido) REFERENCES public.pedidos(id_pedido),
  CONSTRAINT fidelidade_historico_id_referencia_agendamento_fkey FOREIGN KEY (id_referencia_agendamento) REFERENCES public.agendamentos(id_agendamento)
);
CREATE TABLE public.fidelidade_pontos (
  id integer NOT NULL DEFAULT nextval('fidelidade_pontos_id_seq'::regclass),
  id_cliente uuid UNIQUE,
  saldo_pontos numeric DEFAULT 0,
  data_atualizacao timestamp with time zone DEFAULT now(),
  CONSTRAINT fidelidade_pontos_pkey PRIMARY KEY (id),
  CONSTRAINT fidelidade_pontos_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.perfis(id)
);
CREATE TABLE public.fornecedor (
  id_fornecedor integer NOT NULL DEFAULT nextval('fornecedor_id_fornecedor_seq'::regclass),
  cnpj_fornecedor character varying NOT NULL UNIQUE,
  nome_fornecedor character varying NOT NULL,
  produto_fornecido character varying,
  contato_fornecedor character varying,
  CONSTRAINT fornecedor_pkey PRIMARY KEY (id_fornecedor)
);
CREATE TABLE public.funcionarios_detalhes (
  id_perfil uuid NOT NULL,
  funcao_detalhada character varying,
  data_contratacao date NOT NULL,
  salario numeric,
  especialidade text,
  crmv character varying,
  CONSTRAINT funcionarios_detalhes_pkey PRIMARY KEY (id_perfil),
  CONSTRAINT funcionarios_detalhes_id_perfil_fkey FOREIGN KEY (id_perfil) REFERENCES public.perfis(id)
);
CREATE TABLE public.lojas (
  id_loja integer NOT NULL DEFAULT nextval('lojas_id_loja_seq'::regclass),
  nome_loja character varying NOT NULL UNIQUE,
  cnpj_loja character varying UNIQUE,
  endereco text,
  telefone character varying,
  CONSTRAINT lojas_pkey PRIMARY KEY (id_loja)
);
CREATE TABLE public.pedidos (
  id_pedido bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_cliente uuid NOT NULL,
  status_pedido character varying NOT NULL DEFAULT 'processando'::character varying,
  total_pedido numeric NOT NULL,
  data_pedido timestamp with time zone DEFAULT now(),
  CONSTRAINT pedidos_pkey PRIMARY KEY (id_pedido),
  CONSTRAINT pedidos_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.perfis(id)
);
CREATE TABLE public.pedidos_itens (
  id_item_pedido bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_pedido bigint NOT NULL,
  id_produto integer NOT NULL,
  quantidade integer NOT NULL CHECK (quantidade > 0),
  preco_unitario numeric NOT NULL,
  CONSTRAINT pedidos_itens_pkey PRIMARY KEY (id_item_pedido),
  CONSTRAINT pedidos_itens_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES public.pedidos(id_pedido)
);
CREATE TABLE public.perfis (
  id uuid NOT NULL,
  nome_completo text,
  email text UNIQUE,
  cpf character varying UNIQUE,
  endereco text,
  telefone character varying,
  role character varying NOT NULL DEFAULT 'cliente'::character varying,
  CONSTRAINT perfis_pkey PRIMARY KEY (id),
  CONSTRAINT perfis_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.pets (
  id_pet bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_tutor uuid NOT NULL,
  nome_pet text NOT NULL,
  especie character varying,
  raca character varying,
  porte character varying,
  data_nascimento date,
  observacoes text,
  CONSTRAINT pets_pkey PRIMARY KEY (id_pet),
  CONSTRAINT pets_id_tutor_fkey FOREIGN KEY (id_tutor) REFERENCES public.perfis(id)
);
CREATE TABLE public.produtos (
  id_produto integer NOT NULL,
  nome_produto character varying NOT NULL,
  url_imagem text,
  tipo_produto character varying,
  subcategoria character varying,
  marca character varying,
  fabricante character varying,
  descricao text,
  cor character varying,
  tamanho_medida character varying,
  preco numeric NOT NULL DEFAULT 0.00,
  preco_promocional numeric,
  data_fabricacao date,
  data_validade date,
  quantidade_estoque integer NOT NULL DEFAULT 0 CHECK (quantidade_estoque >= 0),
  status_produto character varying,
  data_cadastro timestamp with time zone DEFAULT now(),
  data_atualizacao timestamp with time zone,
  observacoes text,
  CONSTRAINT produtos_pkey PRIMARY KEY (id_produto)
);
CREATE TABLE public.servicos (
  id_servico integer NOT NULL DEFAULT nextval('servicos_id_servico_seq'::regclass),
  nome_servico character varying NOT NULL UNIQUE,
  descricao text,
  duracao_media_minutos integer,
  preco_servico numeric NOT NULL,
  CONSTRAINT servicos_pkey PRIMARY KEY (id_servico)
);
CREATE TABLE public.servicos_loja_regras (
  id_regra integer NOT NULL DEFAULT nextval('servicos_loja_regras_id_regra_seq'::regclass),
  id_loja integer NOT NULL,
  id_servico integer NOT NULL,
  capacidade_simultanea integer NOT NULL DEFAULT 1 CHECK (capacidade_simultanea > 0),
  ativo boolean NOT NULL DEFAULT true,
  CONSTRAINT servicos_loja_regras_pkey PRIMARY KEY (id_regra),
  CONSTRAINT servicos_loja_regras_id_loja_fkey FOREIGN KEY (id_loja) REFERENCES public.lojas(id_loja),
  CONSTRAINT servicos_loja_regras_id_servico_fkey FOREIGN KEY (id_servico) REFERENCES public.servicos(id_servico)
);

