module Darwinning
  module EvolutionTypes
    class Reproduction

      # Available crossover_methods:
      #   :alternating_swap
      #   :random_swap
      def initialize(options = {})
        @crossover_method = options.fetch(:crossover_method, :alternating_swap)
        @organism_options = options.fetch(:organism_options, {})
      end

      def evolve(m1, m2)
        sexytimes(m1, m2)
      end

      def pairwise?
        true
      end

      protected

      def sexytimes(m1, m2)
        raise "Only organisms of the same type can breed" unless m1.class == m2.class

        new_genotypes = send(@crossover_method, m1, m2)

        organism_klass = m1.class
        organism1 = new_member_from_genotypes(organism_klass, new_genotypes.first)
        organism2 = new_member_from_genotypes(organism_klass, new_genotypes.last)

        [organism1, organism2]
      end

      def new_member_from_genotypes(organism_klass, genotypes)
        new_member = organism_klass.new(@organism_options)
        if organism_klass.superclass == Darwinning::Organism
          new_member.genotypes = genotypes
          if new_member.genotypes.values.include? nil
            byebug
          end
        else
          new_member.genes.each do |gene|
            new_member.send("#{gene.name}=", genotypes[gene.name])
          end
        end
        new_member
      end

      def alternating_swap(m1, m2)
        genotypes1 = {}
        genotypes2 = {}

        m1.genes.each_with_index do |gene, i|
          if i % 2 == 0
            genotypes1[gene.name] = m1.genotypes[gene.name]
            genotypes2[gene.name] = m2.genotypes[gene.name]
          else
            genotypes1[gene.name] = m2.genotypes[gene.name]
            genotypes2[gene.name] = m1.genotypes[gene.name]
          end
        end

        [genotypes1, genotypes2]
      end

      def random_swap(m1, m2)
        genotypes1 = {}
        genotypes2 = {}

        m1.genes.each do |gene|
          g1_parent = [m1,m2].sample
          g2_parent = [m1,m2].sample

          genotypes1[gene.name] = g1_parent.genotypes[gene.name]
          genotypes2[gene.name] = g2_parent.genotypes[gene.name]
        end

        if genotypes1.values.include?(nil) || genotypes2.values.include?(nil)
          byebug
        end

        [genotypes1, genotypes2]
      end
    end
  end
end
